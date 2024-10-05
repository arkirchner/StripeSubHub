# frozen_string_literal: true

class AddProcessingErrorToStripeEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :stripe_events, :processing_error, :string, default: "", null: false
  end
end
