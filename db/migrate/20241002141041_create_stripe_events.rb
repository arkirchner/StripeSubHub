class CreateStripeEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_events, id: false do |t|
      t.string :stripe_id, primary_key: true
      t.string :event_type, null: false
      t.json :data, null: false
      t.timestamp :stripe_created_at, null: false

      t.timestamp :created_at, null: false
    end
  end
end
