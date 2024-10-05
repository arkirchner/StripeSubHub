# frozen_string_literal: true

require "test_helper"

class StripeEvents::InvoiceServiceTest < ActiveSupport::TestCase
  test ".call, should create a invoice with a create event" do
    event = create_event("invoice.created")
    invoice = assert_difference "StripeInvoice.count" do
      StripeEvents::InvoiceService.call(event)
    end

    assert_equal event.object.id, invoice.stripe_id
    assert_equal event.stripe_created_at, invoice.last_stripe_event_created_at
    assert_equal event.object.status, invoice.status
  end

  test ".call, should create a invoice with an update event" do
    event = create_event("invoice.updated")
    invoice = assert_difference "StripeInvoice.count" do
      StripeEvents::InvoiceService.call(event)
    end

    assert_equal event.object.id, invoice.stripe_id
  end

  test ".call, should update the invoice" do
    event = create_event("invoice.created")
    invoice = StripeEvents::InvoiceService.call(event)

    event = create_event("invoice.updated")
    event.data["object"]["status"] = "void"

    StripeEvents::InvoiceService.call(event)

    assert_equal event.stripe_created_at, invoice.reload.last_stripe_event_created_at
    assert_equal "void", invoice.reload.status
  end

  test ".call, should not update a invoice with a stale event" do
    event = create_event("invoice.created")
    invoice = StripeEvents::InvoiceService.call(event)

    event = create_event("invoice.created")
    event.data["object"]["status"] = "void"

    StripeEvents::InvoiceService.call(event)

    assert_not_equal "void", invoice.reload.status
  end

  test ".call, should not override stale data in a race condition" do
    update_event = create_event("invoice.updated")

    invoice = StripeEvents::InvoiceService.call(create_event("invoice.created"))

    StripeEvents::InvoiceService.call(update_event)

    StripeInvoice.stub(:find_or_initialize_by, ->(_args) { invoice }) do
      assert_raises(ActiveRecord::StaleObjectError) do
        StripeEvents::InvoiceService.call(update_event)
      end
    end
  end

  def create_event(event_type)
    file_path = "test/fixtures/stripe_events/#{event_type}.json"

    StripeEvent.import(Stripe::Event.construct_from(JSON.parse(File.read(file_path))))
  end
end
