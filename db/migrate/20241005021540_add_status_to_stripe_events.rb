class AddStatusToStripeEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :stripe_events, :status, :integer, default: 0, null: false
  end
end
