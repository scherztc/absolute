class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Connects this user object to Sufia behaviors. 
  include Sufia::User
  # Connects this user object to Hydra behaviors. 
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles


  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4

  devise :cas_authenticatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    user_key
  end
end
