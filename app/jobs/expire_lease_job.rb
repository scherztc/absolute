class ExpireLeaseJob
  @queue = :lease

  def self.perform
    Hydra::LeaseService.assets_with_expired_leases.each do |asset|
      asset.lease_visibility!
      asset.save!
    end
  end
end
