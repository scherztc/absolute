module RegistersHandles
  extend ActiveSupport::Concern

  included do
    around_create :register_handle
  end

  def register_handle
    @make_handle = true if needs_handle?
    yield.tap do |result|
      make_handle! if result && @make_handle
    end
  end

  private

    # Current assumption is that files that are created and a pid is
    # specified are imported files, thus they don't need a handle
    # registered (the importer modifies their existing handle)
    def needs_handle?
      pid.nil?
    end

    def make_handle!
      @make_handle = false
      queue = Absolute::Queue::Handle::Create.new(Resque.redis, JSON)
      queue.push(id: id, url: Rails.application.routes.url_helpers.send(:"curation_concern_#{ActiveModel::Naming.singular_route_key(self)}_url", self.id, url_params))
    end

    def url_params
      { host: 'library.case.edu', script_name: Rails.application.config.relative_url_root }
    end
end
