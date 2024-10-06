# frozen_string_literal: true

class StripeSubscription < ApplicationRecord
  enum :subscription_state, %i[unpaid paid canceled]
end
