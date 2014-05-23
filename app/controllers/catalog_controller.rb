class CatalogController < ApplicationController
  include Worthwhile::CatalogController
  CatalogController.solr_search_params_logic += [:default_parameters]
  
  def default_parameters(solr_params, _)
    unless has_search_parameters?
      solr_params[:fq] ||= []
      solr_params[:fq] << [ActiveFedora::SolrService.construct_query_for_rel(has_model: Collection.to_class_uri)]
    end
  end
end
