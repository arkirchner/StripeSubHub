# frozen_string_literal: true


module StripeEvents
  class PaidInvoiceService
    EVENT_TYPE = "invoice.paid"

    def self.call(event) = new(event).call

    def initialize(event)
      raise ArgumentError, "Event type must be #{EVENT_TYPE}" unless event.event_type == EVENT_TYPE

      @event = event
    end

    def call
      return if event_stale?

      subscription.paid!
    end

    private

    attr_reader :event

    def invoice_id = event.object.id

    def event_stale?
      subscription.canceled?
    end

    def subscription
      @subscription ||= StripeSubscription.find_by!(latest_invoice_id: invoice_id)
    end
  end
end
