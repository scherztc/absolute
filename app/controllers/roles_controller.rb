class RolesController < ApplicationController
  include Hydra::RoleManagement::RolesBehavior
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'
end
