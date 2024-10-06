# frozen_string_literal: true


module StripeEvents
  class DeleteSubscriptionService
    EVENT_TYPE = "customer.subscription.deleted"

    def self.call(event) = new(event).call

    def initialize(event)
      raise ArgumentError, "Event type must be #{EVENT_TYPE}" unless event.event_type == EVENT_TYPE

      @event = event
    end

    def call
      subscription.canceled!
    end

    private

    attr_reader :event

    def stripe_id = event.object.id
    def subscription = StripeSubscription.find(stripe_id)
  end
end
