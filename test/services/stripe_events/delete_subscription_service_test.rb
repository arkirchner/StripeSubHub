# frozen_string_literal: true

require "test_helper"

class StripeEvents::DeleteSubscriptionServiceTest < ActiveSupport::TestCase
  test ".call, should cancel the subscription" do
    subscription = StripeSubscription.create!(
      stripe_id: subscription_deleted_event.object.id,
      first_invoice_id: subscription_deleted_event.object.latest_invoice
    )

    assert_changes -> { subscription.reload.subscription_state }, from: "unpaid", to: "canceled" do
      StripeEvents::DeleteSubscriptionService.call(subscription_deleted_event)
    end
  end

  test ".call, should raise an error if the event type is not 'customer.subscription.created'" do
    event = subscription_deleted_event
    event.event_type = "customer.subscription.created"

    assert_raises(ArgumentError, "Event type must be customer.subscription.created") do
      StripeEvents::DeleteSubscriptionService.call(event)
    end
  end

  def subscription_deleted_event
    file_path = "test/fixtures/stripe_events/customer.subscription.deleted.json"

    StripeEvent.import(Stripe::Event.construct_from(JSON.parse(File.read(file_path))))
  end
end
