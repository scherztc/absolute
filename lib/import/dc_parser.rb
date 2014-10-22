class MultipleValuesError < StandardError
  def initialize(field_name=nil)
    message = "Multiple values were found for single-value field: #{field_name}"
    super(message)
  end
end


class DcParser < ActiveFedora::QualifiedDublinCoreDatastream

  # Warning: This is a kludge!
  #
  # We want to parse a DC datastream, and the
  # ActiveFedora::QualifiedDublinCoreDatastream class almost
  # does what we want, so I extended that class, and changed
  # all the DCTERMS stuff to DC to make it work.
  #
  # In the future, we probably want to transform the DC
  # datastream to RDF instead.

  DC_URL = "http://purl.org/dc/elements/1.1/"

  def initialize(digital_object=nil, dsid=nil, options={})
    super
    field :content_format, :string, path: 'format'
  end

  set_terminology do |t|
    t.root(:path => "dc", :xmlns => DC_URL)
  end

  def field(name, tupe=nil, opts={})
    fields ||= {}
    @fields[name.to_s.to_sym]={:type=>tupe, :values=>[]}.merge(opts)
    # add term to template
    self.class.class_fields << name.to_s
    # add term to terminology
    unless self.class.terminology.has_term?(name.to_sym)
      om_term_opts = {:xmlns => DC_URL, :namespace_prefix => "dc", :path => opts[:path]}
      term = OM::XML::Term.new(name.to_sym, om_term_opts, self.class.terminology)
      self.class.terminology.add_term(term)
      term.generate_xpath_queries!
    end
  end

  def to_h
    single_value_fields = [:description, :rights, :title]
    multi_value_fields = [:content_format, :contributor, :creator, :coverage, :date, :extent, :identifier, :language, :publisher, :relation, :requires, :source, :subject, :type]
    all_fields = single_value_fields + multi_value_fields

    new_lines = /\s*\n\s*/
    attrs_hash = {}
    all_fields.each do |field|
      value = Array(self.send(field))

      if field == :title
        value = [value.join(" | ")]
      end

      if field == :description
        value = [value.join(" ")]
      end

      if single_value_fields.include?(field) && value.count > 1
        raise MultipleValuesError.new(field)
      end

      unless value.blank?
        value = value.map{|v| v.gsub(new_lines, " ") }
        attrs_hash[field] = value
      end
    end
    attrs_hash
  end

end
