class Ability
  include Hydra::Ability
  include Worthwhile::Ability

  # Define any customized permissions here.
  def custom_permissions
    admin_permissions if current_user.admin?
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
    can :manage, Resque
    can :manage, :bulk_update
  end

  private

  def curation_concerns
    Worthwhile.configuration.curation_concerns
  end
end
