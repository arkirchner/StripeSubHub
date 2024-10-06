# frozen_string_literal: true

require "test_helper"

class StripeEvents::CreateSubscriptionServiceTest < ActiveSupport::TestCase
  test ".call, should create a subscription with a create event" do
    subscription = assert_difference "StripeSubscription.count", 1 do
      StripeEvents::CreateSubscriptionService.call(subscription_created_event)
    end

    assert_equal subscription_created_event.object.id, subscription.stripe_id
    assert_equal subscription_created_event.object.latest_invoice, subscription.first_invoice_id
  end

  test ".call, should not update or override a created subscription" do
    StripeEvents::CreateSubscriptionService.call(subscription_created_event)

    assert_raises(ActiveRecord::RecordNotUnique) do
      StripeEvents::CreateSubscriptionService.call(subscription_created_event)
    end
  end

  test ".call, should raise an error if the event type is not 'customer.subscription.created'" do
    event = subscription_created_event
    event.event_type = "customer.subscription.deleted"

    assert_raises(ArgumentError, "Event type must be customer.subscription.created") do
      StripeEvents::CreateSubscriptionService.call(event)
    end
  end

  def subscription_created_event
    file_path = "test/fixtures/stripe_events/customer.subscription.created.json"

    StripeEvent.import(Stripe::Event.construct_from(JSON.parse(File.read(file_path))))
  end
end
