class LegacyObject < Hash
  class ValidationError < StandardError; end

  def initialize(other_hash = {})
    other_hash.each_pair do |key, value|
      self[key] = value
    end
  end

  def pid= pid
    self[:pid] = pid
  end

  def pid
    self[:pid]
  end
  
  def validate!
    validate_collection_members!
    raise ValidationError, "Rights assertion blank for #{pid}." if self[:rights].blank?
    unless self[:rights].all? { |right| Sufia.config.cc_licenses.include?(right) }
      raise ValidationError, "Rights assertion for #{pid}: \"#{self[:rights]}\" was not in the allowed list."
    end
    true
  end

  def validate_collection_members!
    return if self[:member_ids].blank?
    missing_members = self[:member_ids].inject([]) { |missing_members, pid|
      unless ActiveFedora::Base.exists?(pid)
        missing_members << pid
      end
    }
    unless missing_members.blank?
      raise ValidationError, "Unable to create collection #{self[:pid]} because the following collection members do not exist: #{missing_members}"
    end
  end

  # If the attributes contains an entry with a key of language and a value of 'en' recode it as 'eng'
  def []= (key, val)
    if key == :language
      super(:language, val.map { |v| v == 'en' ? 'eng' : v  })
    else
      super
    end
  end
end
