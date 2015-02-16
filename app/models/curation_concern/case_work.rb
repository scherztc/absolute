module CurationConcern::CaseWork
  extend ActiveSupport::Concern
  include CurationConcern::Work
  include CurationConcern::WithDatastreamAttachments
  include CurationConcern::WithBasicMetadata
  include CurationConcern::WithLicense
  #include RegistersHandles

  # override sufia
  def to_param
    pid
  end

  def export_as_endnote
    endnote_format = {
      '%T' => [:title],
      '%A' => [:creator],
      '%C' => [:publication_place],
      '%D' => [:date_created],
      '%8' => [:date_uploaded],
      '%E' => [:contributor],
      '%I' => [:publisher],
      '%R' => [:identifier],
      '%X' => [:description],
      '%G' => [:language],
      '%[' => [:date_modified],
      '%9' => [:resource_type],
      '%~' => Absolute::Application::config.application_name,
      '%W' => 'Case Western Reserve University'
    }
    text = []
    text << "%0 #{self.class.name}"
    endnote_format.each do |endnote_key, mapping|
      values = []
      if mapping.is_a? String
        values = [mapping]
      else
        values = self.send(mapping[0]) if self.respond_to? mapping[0]
        values = mapping[1].call(values) if mapping.length == 2
        values = [values] unless values.is_a? Array
      end
      next if values.empty? or values.first.nil?
      spaced_values = values.join("; ")
      text << "#{endnote_key} #{spaced_values}"
    end
    return text.join("\n")
  end

end
