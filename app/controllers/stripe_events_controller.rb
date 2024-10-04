# frozen_string_literal: true

class StripeEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(payload, signature, ENV.fetch("STRIPE_ENDPOINT_SECRET"))
    StripeEvent.import(event)

    head :no_content
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end
end
