# frozen_string_literal: true

require "test_helper"

class StripeEventTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".import, creates a new StripeEvent" do
    event = assert_difference "StripeEvent.count" do
              StripeEvent.import(new_event)
            end

    assert_equal new_event.id, event.stripe_id
    assert_equal "customer.subscription.created", event.event_type
    assert_equal new_event.data.as_json, event.data
    assert_equal Time.zone.at(new_event.created), event.stripe_created_at
  end

  test ".import, ignores events that have already been imported" do
    StripeEvent.import(new_event)

    assert_no_difference "StripeEvent.count" do
      StripeEvent.import(new_event)
    end
  end

  test ".import, enqueuss the StripeEvent for later processing" do
    args_matcher = ->(args) { assert_instance_of StripeEvent, args[0] }

    assert_enqueued_with(job: StripeEventJob, args: args_matcher) do
      StripeEvent.import(new_event)
    end
  end

  def new_event
    file_path = "test/fixtures/stripe_events/customer.subscription.created.json"

    Stripe::Event.construct_from(JSON.parse(File.read(file_path)))
  end
end
