module Hydra::RemoteIdentifier::RemoteServices

  class NonexistantHandleError < StandardError; end
  class HandleAlreadyExistsError < StandardError; end

  class HandleService < Hydra::RemoteIdentifier::RemoteService

    def namespace
      return @namespace if @namespace
      handle_config = Rails.root.join('config','handle.yml')
      config = ERB.new(IO.read(handle_config)).result(binding)
      @namespace = Psych.load(config)[Rails.env]['namespace'].to_s
    end

    def handle_exists?(handle)
      url = URI.parse(handle)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
      res.code == "303" ? true : false
    end

    def data_for_update(handle, location)
      raise NonexistantHandleError unless handle_exists?("http://hdl.handle.net/#{namespace}/#{handle}")
      update =  "MODIFY #{namespace}/#{handle}\n"
      update += "2 URL 86400 1110 UTF8 #{location}\n"
      return update
    end

    def data_for_create(new_handle, location)
      raise HandleAlreadyExistsError if handle_exists("http://hdl.handle.net/#{namespace}/#{new_handle}")
      create =  "CREATE #{namespace}/#{new_handle}\n"
      create += "100 HS_ADMIN 86400 1110 ADMIN\n"
      create += "200::111111111111:0.NA/#{namespace}\n"
      create += "2 URL 86400 1110 UTF8 #{location}\n\n"
      return create
    end

    def data_for_delete(handle)
      raise NonexistantHandleError unless handle_exists("http://hdl.handle.net/#{namespace}/#{handle}")
      return "DELETE #{namespace}/#{handle}\n"
    end

  end
end
