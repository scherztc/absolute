module Export
  class Handles
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TextHelper
    

    def initialize(verb, namespace, host, pids=nil)
      @verb = verb
      @namespace = namespace
      @host = host 
      @pids = pids
    end

    def export!
      counter = 0
      File.open(file_name, 'w') do |f|
        ActiveFedora::SolrService.query(query, fl: 'id has_model_ssim').each do |doc|
          counter += 1
          f.puts modify(* model_and_id(doc))
        end
      end
      puts "Exported #{pluralize(counter, "#{@verb} record")} to #{file_name}"
    end

    private
      def query
        q = "has_model_ssim:(#{query_classes.join(' ')})"
        q += " AND (#{ActiveFedora::SolrService.construct_query_for_pids(@pids)})" if @pids
        q
      end

      def classes
        Worthwhile.configuration.registered_curation_concern_types.map(&:constantize) + [Collection]
      end

      def query_classes
        classes.map { |klass| "\"#{klass.to_class_uri}\"" }
      end

      def modify(model, id)
        "#{@verb} #{@namespace}/#{id}\n" +
        "2 URL 86400 1110 UTF8 #{route_for(model, id)}\n\n"
      end

      def route_for(model, id)
        if model == Collection
          collection_url id, url_params
        else
          send(:"curation_concern_#{model.to_s.underscore}_url", id, url_params)
        end
      end

      def url_params
        { host: @host, script_name: Rails.application.config.relative_url_root }
      end

      def model_and_id(doc)
        model = ActiveFedora::Model.from_class_uri(doc['has_model_ssim'].first)
        return model, doc['id']
      end

      def file_name
        @file_name ||= "#{@verb.downcase}-handles-#{Time.now.to_formatted_s(:iso8601).first(19)}.txt"
      end
  end
end
