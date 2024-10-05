# frozen_string_literal: true


module StripeEvents
  class SubscriptionService
    def self.call(event) = new(event).call

    def initialize(event)
      @event = event
    end

    def call = nil

    private

    attr_reader :event
  end
end
