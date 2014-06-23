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

  def visibility= visibility
    self[:visibility] = visibility
  end

  def pid
    self[:pid]
  end
  
  def validate!
    raise ValidationError, "Rights assertion blank for #{pid}." if self[:rights].blank?
    true
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
