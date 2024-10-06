# frozen_string_literal: true


module StripeEvents
  class CreateSubscriptionService
    EVENT_TYPE = "customer.subscription.created"

    def self.call(event) = new(event).call

    def initialize(event)
      raise ArgumentError, "Event type must be #{EVENT_TYPE}" unless event.event_type == EVENT_TYPE

      @event = event
    end

    def call
      StripeSubscription.create!(stripe_id:, first_invoice_id:)
    end

    private

    attr_reader :event

    def stripe_id = event.object.id
    def first_invoice_id = event.object.latest_invoice
  end
end
