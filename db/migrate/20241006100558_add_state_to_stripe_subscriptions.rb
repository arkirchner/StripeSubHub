# frozen_string_literal: true

class AddStateToStripeSubscriptions < ActiveRecord::Migration[8.0]
  def change
    remove_column :stripe_subscriptions, :status, :integer, null: false
    add_column :stripe_subscriptions, :subscription_state, :integer, null: false, default: 0
  end
end
