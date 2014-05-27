require 'import/dc_parser'
require 'import/dsid_map'

class ObjectImporter

  attr_reader :failed_imports

  def initialize(remote_fedora, pids, verbose = false)
    @remote_fedora_name = remote_fedora
    @pids = pids
    @verbose = verbose
  end

  def import!
    @failed_imports = []
    fedora = connect_to_remote_fedora
    @pids.each_with_index do |pid, i|
      print_output "Importing record #{i + 1} of #{@pids.count} : #{pid}"
      import_object(pid, fedora)
    end
    print_output(final_import_status)
  end

  def connect_to_remote_fedora
    fedora_config_file = Rails.root.join('config', 'fedora.yml')
    config_erb = ERB.new(IO.read(fedora_config_file)).result(binding)
    credentials = Psych.load(config_erb)[@remote_fedora_name]
    print_output "Connecting to #{credentials['url']}"
    Rubydora.connect credentials
  end

  def import_object(pid, fedora)
    source_object = fedora.find(pid)
    dc_attrs = DcParser.from_xml(source_object.datastreams['DC'].content).to_attrs_hash
    new_object = work_class(source_object).new(dc_attrs)
    copy_datastreams(source_object, new_object)
    new_object.rights = license
    new_object.save!
    attach_files(source_object, new_object)
  rescue => e
    @failed_imports << pid
    print_output "    ERROR: Failed to import object: #{pid}"
    print_output "    " + e.message
  end

  def work_class(source_object)
    # TODO: Choose an approprate type of work to create based
    # on xml attachment data streams.
    #   TEI  => Text
    #   PBCore => Video
    #   VRA => Image
    #   Otherwise make it a CaseGenericWork
    # Or possibly look at the value of dc:type to decide.

    CaseGenericWork
  end

  def license
    # TODO: If they already have something in this field, we
    #       probably shouldn't clobber it.
    # TODO: What should the default license be?
    Sufia.config.cc_licenses['All rights reserved']
  end

  def copy_datastreams(source_object, new_object)
    xml_datastreams = dsid_hash(source_object)[:xml]
    xml_datastreams.each do |dsid|
      print_output "    Copying datastream: #{dsid}"
      source_datastream = source_object.datastreams[dsid]
      target_dsid = DsidMap.target_dsid(dsid)
      options = { dsid: target_dsid, mimeType: source_datastream.mimeType }
      new_object.add_file_datastream(source_datastream.content, options)
    end
  end

  def attach_files(source_object, new_object)
    files_to_attach = dsid_hash(source_object)[:attached_files]
    files_to_attach.each do |dsid|
      source_datastream = source_object.datastreams[dsid]
      Worthwhile::GenericFile.new(batch_id: new_object.pid).tap do |file|
        file.add_file(source_datastream.content, 'content', dsid)
        file.save!
        print_output("    Handling datastream #{dsid}: Created GenericFile #{file.pid}")
      end
    end
  end

  # Sort the source object's datastreams based on how we want to handle them.
  # XML datastreams can just be copied straight from the source object.
  # For other types of datastreams, we will create a new generic file
  # and attach it to the new object (has to be done after the PID has
  # been assigned to the new object).
  def dsid_hash(source_object)
    # TODO: Decide if we should import RELS-EXT
    exclude_datastreams = ['RELS-EXT', 'DC', 'descMetadata']
    datastreams_to_import = source_object.datastreams.keys - exclude_datastreams

    dsids = { xml: [], attached_files: [] }
    datastreams_to_import.each do |dsid|
      source_datastream = source_object.datastreams[dsid]
      xml_datastream = ['text/xml', 'application/xml'].include?(source_datastream.mimeType)
      key = xml_datastream ? :xml : :attached_files
      dsids[key] << dsid
    end
    dsids
  end

  def print_output(message)
    puts message if @verbose
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
