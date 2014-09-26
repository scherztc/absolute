#Note: the line 'module Sufia' was removed from this file so the class would initialize
class ResqueAdmin
  def self.matches?(request)
    current_user = request.env['warden'].user
    return false if current_user.blank?
    # Finds the abilities of the current user. Right now, :manage, Resque is only given to admins
    Ability.new(current_user).can? :manage, Resque
    # I think this is done in the above line.
    # TODO code a group here that makes sense
    #current_user.groups.include? 'umg/up.dlt.scholarsphere-admin'
  end
end
