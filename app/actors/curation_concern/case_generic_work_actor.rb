module CurationConcern
  class CaseGenericWorkActor < CurationConcern::GenericWorkActor
    include RegistersHandles

    def create
      super && save_attachments
    end

    def update
      super && save_attachments
    end

    protected

    def save_attachments
      dirty = false
      curation_concern.attachments.each do |dsid,ds|
        if attributes[dsid]
          ds.content = attributes[dsid]
          dirty = true
        end
      end
      if dirty
        curation_concern.save
      else
        true
      end
    end

  end
end
