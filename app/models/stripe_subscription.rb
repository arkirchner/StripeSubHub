# frozen_string_literal: true

class StripeSubscription < ApplicationRecord
  enum :subscription_state, %i[unpaid paid canceled]

  def cancel
    raise "Only paid subscriptions can be canceled" unless paid?

    ActiveRecord::Base.transaction do
      canceled!
      Stripe::Subscription.cancel(stripe_id)
    end
  end
end
