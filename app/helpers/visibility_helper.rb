module VisibilityHelper
  def human_readable_visibility(visibility)
    if visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      'Case Western Reserve University'
    else
      visibility
    end
  end
end
