module CurationConcern::WithLicense
  extend ActiveSupport::Concern
  included do
    validates_presence_of :rights, message: 'You must select a license for your work.'
  end
end
