class User < ActiveRecord::Base

  # Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Connects this user object to Sufia behaviors. 
  include Sufia::User
  # Connects this user object to Hydra behaviors. 
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  devise :cas_authenticatable

  # Overridden because we don't use password
  def self.batchuser
    User.find_by_user_key(batchuser_key) || User.create!(Devise.authentication_keys.first => batchuser_key)
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    user_key
  end
end
