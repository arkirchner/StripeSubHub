class StripeEvent < ApplicationRecord
  def self.import(event)
    create_or_find_by(stripe_id: event.id) do |stripe_event|
      stripe_event.event_type = event.type
      stripe_event.data = event.data
      stripe_event.stripe_created_at = Time.zone.at(event.created)
    end
  end
end
