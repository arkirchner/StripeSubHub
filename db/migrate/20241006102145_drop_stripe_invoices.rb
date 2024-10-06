# frozen_string_literal: true

class DropStripeInvoices < ActiveRecord::Migration[8.0]
  def change
    drop_table :stripe_invoices, id: false do |t|
      t.string :stripe_id, primary_key: true
      t.integer :status, null: false
      t.timestamp :last_stripe_event_created_at, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end
  end
end
