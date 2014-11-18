# This migration comes from mailboxer_engine (originally 20131206080417)
class AddMissingIndices < ActiveRecord::Migration
  def change
    # We'll explicitly specify its name, as the auto-generated name is too long and exceeds 63
    # characters limitation.
    add_index :mailboxer_convers_opt_outs, [:unsubscriber_id, :unsubscriber_type],
      name: 'i_mail_con_opt_out_uns_id_type'
    add_index :mailboxer_convers_opt_outs, :conversation_id

    add_index :mailboxer_notifications, :type
    add_index :mailboxer_notifications, [:sender_id, :sender_type]

    # We'll explicitly specify its name, as the auto-generated name is too long and exceeds 63
    # characters limitation.
    add_index :mailboxer_notifications, [:notified_object_id, :notified_object_type],
      name: 'i_mai_not_not_obj_id_type'

    add_index :mailboxer_receipts, [:receiver_id, :receiver_type]
  end
end
