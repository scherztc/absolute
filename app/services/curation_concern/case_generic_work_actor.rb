# Generated via
#  `rails generate curate:work Text`
module CurationConcern
  class CaseGenericWorkActor < CurationConcern::GenericWorkActor
    
    def create
      super && save_attachments
    end

    def update
      super && save_attachments
    end
    
    protected

    def save_attachments
      dirty = false
      [:TEI, :TEIP5, :MODS].each do |ds_key|
        if attributes[ds_key]
          curation_concern.datastreams[ds_key.to_s].content = attributes[ds_key]
          dirty = true
        end
      end
      if dirty
        return curation_concern.save 
      else
        return true
      end
    end
    
  end
end
