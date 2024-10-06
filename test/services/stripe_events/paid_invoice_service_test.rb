# frozen_string_literal: true

require "test_helper"

class StripeEvents::PaidInvoiceServiceTest < ActiveSupport::TestCase
  test ".call, should update the subscription state to paid" do
    subscription = StripeSubscription.create!(
      id: "sub_123",
      latest_invoice_id: invoice_paid_event.object.id,
      last_stripe_event_created_at: Time.current,
    )

    assert_changes -> { subscription.reload.subscription_state }, from: "unpaid", to: "paid" do
      StripeEvents::PaidInvoiceService.call(invoice_paid_event)
    end
  end

  test ".call, should not update a canceled subscription" do
    subscription = StripeSubscription.create!(
      id: "sub_123",
      subscription_state: "canceled",
      latest_invoice_id: invoice_paid_event.object.id,
      last_stripe_event_created_at: Time.current,
    )

    assert_no_changes -> { subscription.reload.subscription_state } do
      StripeEvents::PaidInvoiceService.call(invoice_paid_event)
    end
  end

  test ".call, should not override stale data in a race condition" do
    subscription = StripeSubscription.create!(
      id: "sub_123",
      latest_invoice_id: invoice_paid_event.object.id,
      last_stripe_event_created_at: Time.current,
    )

    StripeEvents::PaidInvoiceService.call(invoice_paid_event)

    StripeSubscription.stub(:find_by!, ->(_args) { subscription }) do
      assert_raises(ActiveRecord::StaleObjectError) do
        StripeEvents::PaidInvoiceService.call(invoice_paid_event)
      end
    end
  end

  test ".call, should raise an error if the event type is not 'invoice.paid'" do
    invoice_paid_event.event_type = "customer.subscription.created"

    error = assert_raises(ArgumentError) do
      StripeEvents::PaidInvoiceService.call(invoice_paid_event)
    end

    assert_equal "Event type must be invoice.paid", error.message
  end

  def invoice_paid_event
    file_path = "test/fixtures/stripe_events/invoice.paid.json"

    @invoice_paid_event ||= StripeEvent.import(Stripe::Event.construct_from(JSON.parse(File.read(file_path))))
  end
end
