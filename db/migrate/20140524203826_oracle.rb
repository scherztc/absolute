class Oracle < ActiveRecord::Migration
  def change
       # pattern for upward migration is
       # rename_table :old_table_name, :new_table_name
       # rename_column :affected_table, :old_column_name, :new_column_name
       rename_table :subject_local_authority_entries, :subject_local_auth_entries
       rename_column :users, :user_does_not_require_profile_update, :user_no_profile_update
       rename_index :help_requests, 'index_help_requests_on_created_at', 'i_help_requests_created_at' 
       rename_index :mailboxer_notifications, 'index_mailboxer_notifications_on_conversation_id', 'i_mai_not_con_id'
       rename_index :mailboxer_receipts, 'index_mailboxer_receipts_on_notification_id', 'i_mai_rec_not_id'
       rename_index :proxy_deposit_rights, 'index_proxy_deposit_rights_on_grantee_id', 'i_pro_dep_rig_grantee_id'
       rename_index :proxy_deposit_rights, 'index_proxy_deposit_rights_on_grantor_id', 'i_pro_dep_rig_grantor_id'
       rename_index :roles_users, 'index_roles_users_on_role_id_and_user_id', 'i_roles_users_role_id_user_id'
       rename_index :roles_users, 'index_roles_users_on_user_id_and_role_id', 'i_roles_users_user_id_role_id'
       rename_index :users, 'index_users_on_reset_password_token', 'i_users_reset_password_token'
#'requests_by_created_at'
  end
end
