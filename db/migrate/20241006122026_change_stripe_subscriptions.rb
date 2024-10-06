# frozen_string_literal: true

class ChangeStripeSubscriptions < ActiveRecord::Migration[8.0]
  def change
    rename_column :stripe_subscriptions, :latest_invoice_id, :first_invoice_id
    remove_column :stripe_subscriptions, :last_stripe_event_created_at, :timestamp, null: false
  end
end
