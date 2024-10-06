# frozen_string_literal: true

require "test_helper"

class StripeSubscriptionTest < ActiveSupport::TestCase
  test "#cancel, cancels the remote subscription and updates the state" do
    subscription = StripeSubscription.create(
      stripe_id: "sub_123",
      subscription_state: "paid"
    )

    stub = stub_request(:delete, "https://api.stripe.com/v1/subscriptions/sub_123").
      to_return(status: 200, body: "{}")

    assert_changes -> { subscription.subscription_state }, from: "paid", to: "canceled" do
      subscription.cancel
    end

    assert_requested stub
  end

  test "#cancel, only allows the cancelation of paid subscriptions" do
    subscription = StripeSubscription.create(
      stripe_id: "sub_123",
      subscription_state: "unpaid"
    )

    error = assert_raises do
      subscription.cancel
    end

    assert_equal "Only paid subscriptions can be canceled", error.message
  end
end
