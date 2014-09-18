class ExpireLeaseJob
  @queue = :lease

  def self.perform
    Hydra::LeaseService.assets_with_expired_leases.each do |asset|
      asset.lease_visibility!
      asset.copy_visibility_to_files
      asset.save!
    end
  end
end
