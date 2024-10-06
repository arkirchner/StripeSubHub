# frozen_string_literal: true

class AddStatusToStripeSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :stripe_subscriptions, :status, :integer, null: false
  end
end
