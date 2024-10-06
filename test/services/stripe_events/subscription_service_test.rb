# frozen_string_literal: true

require "test_helper"

class StripeEvents::SubscriptionServiceTest < ActiveSupport::TestCase
  test ".call, should create a subscription with a create event" do
    event = create_event("customer.subscription.created")
    subscription = assert_difference "StripeSubscription.count" do
      StripeEvents::SubscriptionService.call(event)
    end

    assert_equal event.object.id, subscription.stripe_id
    assert_equal event.stripe_created_at, subscription.last_stripe_event_created_at
    assert_equal event.object.latest_invoice, subscription.latest_invoice_id
    assert_equal event.object.status, subscription.status
  end

  test ".call, should create a subscription with an update event" do
    event = create_event("customer.subscription.deleted")
    subscription = assert_difference "StripeSubscription.count" do
      StripeEvents::SubscriptionService.call(event)
    end

    assert_equal event.object.id, subscription.stripe_id
  end

  test ".call, should update the subscription" do
    event = create_event("customer.subscription.created")
    subscription = StripeEvents::SubscriptionService.call(event)

    event = create_event("customer.subscription.deleted")
    event.data["object"]["latest_invoice"] = "in_01"

    StripeEvents::SubscriptionService.call(event)

    assert_equal event.stripe_created_at, subscription.reload.last_stripe_event_created_at
    assert_equal "in_01", subscription.reload.latest_invoice_id
    assert_equal "canceled", subscription.reload.status
  end

  test ".call, should not update a subscription with a stale event" do
    event = create_event("customer.subscription.created")
    subscription = StripeEvents::SubscriptionService.call(event)

    event = create_event("customer.subscription.created")
    event.data["object"]["latest_invoice"] = "in_01"

    StripeEvents::SubscriptionService.call(event)

    assert_not_equal "in_01", subscription.reload.latest_invoice_id
  end

  test ".call, should not override stale data in a race condition" do
    deleted_event = create_event("customer.subscription.deleted")

    subscription = StripeEvents::SubscriptionService.call(create_event("customer.subscription.created"))

    StripeEvents::SubscriptionService.call(deleted_event)

    StripeSubscription.stub(:find_or_initialize_by, ->(_args) { subscription }) do
      assert_raises(ActiveRecord::StaleObjectError) do
        StripeEvents::SubscriptionService.call(deleted_event)
      end
    end
  end

  def create_event(event_type)
    file_path = "test/fixtures/stripe_events/#{event_type}.json"

    StripeEvent.import(Stripe::Event.construct_from(JSON.parse(File.read(file_path))))
  end
end
