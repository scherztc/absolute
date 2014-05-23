class Ability
  include Hydra::Ability
  include Worthwhile::Ability
  #self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    admin_permissions if current_user.admin?
    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can :read, :admin_menu
    can [:create, :show, :add_user, :remove_user, :index], Role
    #can [:read, :read_private_collection], Collection
    #can [:read, :create], Hydra::Admin::Collection
    can [:read, :edit, :update, :destroy, :publish], curation_concerns
    can :create, curation_concerns
    can :create, Collection
    can [:destroy], ActiveFedora::Base
  end

  private

  def curation_concerns
    Worthwhile.configuration.curation_concerns
  end
end
