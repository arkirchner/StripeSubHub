# frozen_string_literal: true

class StripeEvent < ApplicationRecord
  enum :status, [ :pending, :processed, :processing_failed, :unhandled ]

  after_create_commit { StripeEventJob.perform_later(self) }

  def self.import(event)
    create_or_find_by(stripe_id: event.id) do |stripe_event|
      stripe_event.event_type = event.type
      stripe_event.data = event.data
      stripe_event.stripe_created_at = Time.zone.at(event.created)
    end
  end
end
