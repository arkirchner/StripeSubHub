# frozen_string_literal: true


module StripeEvents
  class SubscriptionService
    def self.call(event) = new(event).call

    def initialize(event)
      @event = event
    end

    def call
      return subscription if event_stale?

      subscription.assign_attributes(last_stripe_event_created_at:, latest_invoice_id:, status:)
      subscription.save!

      subscription
    end

    private

    attr_reader :event

    def stripe_id = event.object.id
    def last_stripe_event_created_at = event.stripe_created_at
    def latest_invoice_id = event.object.latest_invoice
    def status = event.object.status

    def event_stale?
      subscription.persisted? &&
        event.stripe_created_at <= subscription.last_stripe_event_created_at
    end

    def subscription
      @subscription ||= StripeSubscription.find_or_initialize_by(stripe_id:)
    end
  end
end
