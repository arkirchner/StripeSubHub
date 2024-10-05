# frozen_string_literal: true


module StripeEvents
  class InvoiceService
    def self.call(event) = new(event).call

    def initialize(event)
      @event = event
    end

    def call
      return invoice if event_stale?

      invoice.assign_attributes(last_stripe_event_created_at:, status:)
      invoice.save!

      invoice
    end

    private

    attr_reader :event

    def stripe_id = event.object.id
    def last_stripe_event_created_at = event.stripe_created_at
    def status = event.object.status

    def event_stale?
      invoice.persisted? &&
        event.stripe_created_at <= invoice.last_stripe_event_created_at
    end

    def invoice
      @invoice ||= StripeInvoice.find_or_initialize_by(stripe_id:)
    end
  end
end
