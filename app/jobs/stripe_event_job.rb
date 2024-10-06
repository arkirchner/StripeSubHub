# frozen_string_literal: true

class StripeEventJob < ApplicationJob
  SERVICES = {
    "customer.subscription.created" => StripeEvents::CreateSubscriptionService,
    "customer.subscription.deleted" => StripeEvents::DeleteSubscriptionService,
    "invoice.paid" => StripeEvents::PaidInvoiceService
  }.freeze

  retry_on StandardError, attempts: 10

  queue_as :default

  def perform(stripe_event)
    service = SERVICES[stripe_event.event_type]

    if service
      ActiveRecord::Base.transaction do
        stripe_event.update!(status: :processed, processing_error: "")

        service.call(stripe_event)
      end
    else
      stripe_event.unhandled!
    end
  rescue => error
    stripe_event.update!(status: :processing_failed, processing_error: error.message)

    raise error
  end
end
