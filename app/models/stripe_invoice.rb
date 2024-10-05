# frozen_string_literal: true

class StripeInvoice < ApplicationRecord
  enum :status, %i[draft open paid void uncollectible]
end
