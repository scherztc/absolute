module RegistersHandles
  extend ActiveSupport::Concern

  def create
    @make_handle = true if needs_handle?
    super.tap do |result|
      make_handle! if result && @make_handle
    end
  end

  private

    # Current assumption is that files that are created and a pid is
    # specified are imported files, thus they don't need a handle
    # registered (the importer modifies their existing handle)
    def needs_handle?
      curation_concern.pid.nil?
    end

    def make_handle!
      @make_handle = false
      queue = Absolute::Queue::Handle::Create.new(Resque.redis, JSON)
      queue.push(id: curation_concern.id, url: url)
    end

    def url_params
      { host: 'library.case.edu', script_name: Rails.application.config.relative_url_root }
    end

    def url
      Rails.application.routes.url_helpers.send(url_helper_name, curation_concern.id, url_params)
    end

    def url_helper_name
      :"curation_concern_#{ActiveModel::Naming.singular_route_key(curation_concern)}_url"
    end
end
