require 'import/dsid_map'
require 'import/object_factory'
require 'import/rels_ext_parser'

class UnableToCreateLinkedResourceError < StandardError; end

class ObjectImporter

  attr_reader :failed_imports

  def initialize(remote_fedora_name, pids, verbose = false)
    @remote_fedora_name = remote_fedora_name
    @pids = pids
    @verbose = verbose
  end

  def import!
    @failed_imports = []
    @pids.each_with_index do |pid, i|
      print_output "Importing record #{i + 1} of #{@pids.count} : #{pid}"
      import_object(pid)
    end
    print_output("Log file printed to #{log_file}")
    print_output(final_import_status)
  end

  def remote_fedora
    return @remote_fedora if @remote_fedora
    fedora_config_file = Rails.root.join('config', 'fedora.yml')
    config_erb = ERB.new(IO.read(fedora_config_file)).result(binding)
    credentials = Psych.load(config_erb)[@remote_fedora_name]
    print_output "Connecting to #{credentials['url']}"
    @remote_fedora = Rubydora.connect credentials
  end

  def import_object(pid)
    source_object = remote_fedora.find(pid)
    klass, attributes = ObjectFactory.new(source_object).build_object
    attributes[:rights] = set_rights(attributes[:rights], pid)

    if klass == Collection
      new_object = klass.new(attributes)
      handle_datastreams(source_object, new_object, attributes)
      import_collection(source_object, new_object)
      new_object.save!
    else
      new_object = klass.new(pid: attributes.delete(:pid))
      handle_datastreams(source_object, new_object, attributes)
      actor = Worthwhile::CurationConcern.actor(new_object, User.batchuser, attributes)
      actor.create
    end

    print_output "    Created #{new_object.class} object: #{new_object.pid}"
    set_state(new_object, source_object.state)
  rescue => e
    @failed_imports << pid
    print_output "    ERROR: Failed to import object: #{pid}"
    print_output "    " + e.message
    clean_up_after_failed_import(new_object) if new_object
  end

  def set_rights(rights, pid)
    if rights.blank?
      rights = Sufia.config.cc_licenses.first
      print_output "    WARNING: No dc:rights assertion found for #{pid}.  Setting rights statement for this object."
    else
      unless Array(rights).all? { |right| Sufia.config.cc_licenses.include?(right) }
        print_output "    WARNING: Rights assertion for #{pid} was not in the expected list."
      end
    end
    rights
  end

  def handle_datastreams(source_object, new_object, attributes)
    dsids = classify_datastreams(source_object)
    copy_datastreams(source_object.datastreams.select { |k,_| dsids[:xml].include?(k) }, new_object)
    new_object.generic_file_ids = attach_files(source_object.datastreams.select { |k,_| dsids[:attached_files].include?(k) }, new_object, attributes[:visibility])
    select_representative(new_object)
    if new_object.respond_to?(:linked_resource_ids=)
      attach_links(source_object.datastreams.select { |k,_| dsids[:links].include?(k) }, new_object)
    end
  end

  def copy_datastreams(source_datastreams, new_object)
    source_datastreams.each do |dsid, source_datastream|
      print_output "    Copying datastream: #{dsid}"
      target_dsid = DsidMap.target_dsid(dsid)
      options = { dsid: target_dsid, mimeType: source_datastream.mimeType }
      new_object.add_file_datastream(source_datastream.content, options)
    end
  end

  def attach_files(source_datastreams, new_object, visibility)
    file_ids = []
    source_datastreams.each do |dsid, source_datastream|
      print_output("    Handling datastream #{dsid}:")
      Worthwhile::GenericFile.new(batch_id: new_object.pid).tap do |file|
        file.add_file(source_datastream.content, 'content', dsid)
        file.visibility = visibility
        file.datastreams['content'].dsState = source_datastream.state
        file.save!
        print_output("      Created GenericFile #{file.pid}")

        set_state(file, source_datastream.state)
        file_ids << file.pid
        Sufia.queue.push(CharacterizeJob.new(file.pid))
      end
    end
    file_ids
  end

  def attach_links(source_datastreams, new_object)
    source_datastreams.each do |dsid, source_datastream|
      print_output("    Handling datastream #{dsid}:")
      attrs = { title: source_datastream.label,
                url: source_datastream.dsLocation,
                batch: new_object
      }
      link = Worthwhile::LinkedResource.new(attrs)
      link.datastreams['content'].dsState = source_datastream.state
      actor = Worthwhile::CurationConcern.actor(link, User.batchuser, attrs)
      unless actor.create
        raise UnableToCreateLinkedResourceError.new
      end
      print_output("      Created Linked Resource: #{actor.curation_concern.pid}")
      set_state(link, source_datastream.state)
    end
  end

  # Sort the source object's datastreams based on how we want to handle them during import.
  # For external or redirect datastreams, we'll create a linked resource for the object.
  # XML datastreams can just be copied straight from the source object.
  # For other types of datastreams, we will create a new generic file
  # and attach it to the new object (has to be done after the PID has
  # been assigned to the new object).
  def classify_datastreams(source_object)
    # Exclude DC datastream because that is already being
    # handled when the new object gets initialized.
    exclude_datastreams = ['RELS-EXT', 'DC', 'descMetadata']
    datastreams_to_import = source_object.datastreams.keys - exclude_datastreams

    xml_types = ['text/xml', 'application/xml']

    dsids = { xml: [], attached_files: [], links: [] }
    datastreams_to_import.each do |dsid|
      source_ds = source_object.datastreams[dsid]

      key = if source_ds.external? || source_ds.redirect?
              :links
            elsif xml_types.include?(source_ds.mimeType)
              :xml
            else
              :attached_files
            end
      dsids[key] << dsid
    end
    dsids
  end

  def select_representative(new_object)
    if new_object.generic_file_ids.count == 1 || new_object.class == Collection
      new_object.representative = new_object.generic_file_ids.first
    end
  end

  # Setting state to anything but 'A' requires you to save
  # the object a second time.
  # https://jira.duraspace.org/browse/FCREPO-1212
  def set_state(object, new_state)
    if object.state != new_state
      object.state = new_state
      object.save!
    end
  end

  def import_collection(source_object, new_object)
    rels = source_object.datastreams['RELS-EXT'].content
    member_ids = RelsExtParser.new(rels).collection_member_ids

    existing_members, missing_members = member_ids.partition { |pid| ActiveFedora::Base.exists?(pid) }

    print_output("    Collection #{new_object.pid}: Found #{existing_members.count} members that have already been imported, and #{missing_members.count} members that have not been imported yet.")

    missing_members.each_with_index do |pid, i|
      print_output "    Importing collection member #{i + 1} of #{missing_members.count} : #{pid}"
      import_object(pid)
    end

    new_object.member_ids = member_ids
  end

  def clean_up_after_failed_import(new_object)
    objects_to_delete = new_object.generic_files
    if new_object.respond_to?(:linked_resources)
      objects_to_delete = objects_to_delete + new_object.linked_resources
    end

    unless objects_to_delete.blank?
      print_output "Deleting the following attached objects after failing to import #{new_object.pid} : #{objects_to_delete.map(&:pid)}"
    end

    objects_to_delete.each do |obj|
      if obj.pid && ActiveFedora::Base.exists?(obj.pid)
        obj.destroy
      end
    end
  end

  def print_output(message)
    return unless @verbose
    File.open(log_file, 'a') { |io| io.puts message }
    puts message
  end

  def log_file
    return @log_file if @log_file
    log_dir = File.join(Rails.root, 'log', 'imports')
    FileUtils.mkdir_p(log_dir)
    timestamp = Time.now.strftime("%Y_%m_%d_%H%M%S")
    @log_file = File.join(log_dir, "object_import_#{timestamp}.log")
  end

  def final_import_status
    import_status = "Import finished."
    unless @failed_imports.blank?
      import_status = "\nERROR SUMMARY: " +
        "Failed to import the following objects: " +
        "#{@failed_imports} \n" +
        "Import finished with errors."
    end
    import_status
  end

end
