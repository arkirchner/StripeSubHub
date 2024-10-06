# frozen_string_literal: true

class StripeSubscription < ApplicationRecord
  enum :status, %i[incomplete incomplete_expired trialing active past_due canceled unpaid paused]
end
