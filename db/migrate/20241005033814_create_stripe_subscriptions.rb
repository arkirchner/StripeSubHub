# frozen_string_literal: true

class CreateStripeSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_subscriptions, id: false do |t|
      t.string :stripe_id, primary_key: true
      t.string :latest_invoice_id, null: false, default: '', index: true
      t.timestamp :last_stripe_event_created_at, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end
  end
end
