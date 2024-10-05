# frozen_string_literal: true

require "test_helper"

class StripeEventJobTest < ActiveJob::TestCase
  test "#perform, processes a handeled StripeEvent event" do
    event = create_event("customer.subscription.created")

    mock_call = Minitest::Mock.new
    mock_call.expect(:call, nil, [ event ])

    StripeEvents::SubscriptionService.stub(:call, mock_call) do
      StripeEventJob.perform_now(event)
    end

    assert event.processed?

    assert_mock mock_call
  end

  test "#perform, ignores an unhandled StripeEvent event" do
    event = create_event("unhandled.created")

    StripeEventJob.perform_now(event)

    assert event.unhandled?
  end

  test "#perform, records porcessing errors and raises an exception" do
    event = create_event("customer.subscription.created")

    StripeEvents::SubscriptionService.stub(:call, ->(_event) { raise("processing error abc") }) do
      assert_raises do
        StripeEventJob.perform_now(event)
      end
    end

    assert event.processing_failed?

    assert_equal "processing error abc", event.processing_error
  end

  test "#perform, removes the error message after a successful retry" do
    event = create_event("customer.subscription.created")
    event.update!(status: :processing_failed, processing_error: "processing error abc")

    StripeEventJob.perform_now(event)

    assert event.processed?
    assert_equal "", event.processing_error
  end

  def create_event(event_type)
    StripeEvent.create!(
      id: "evt_test",
      event_type: event_type,
      data: {},
      stripe_created_at: Time.current
    )
  end
end
