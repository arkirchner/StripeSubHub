# frozen_string_literal: true

require "test_helper"

class StripeEventsControllerTest < ActionDispatch::IntegrationTest
  test "create, with valid payload and signature" do
    assert_difference("StripeEvent.count") do
      post(stripe_events_path, params: event_params, headers:, as: :json)
    end

    assert_response :no_content
  end

  test "create, with invalid payload" do
    post(stripe_events_path, params: { foo: :bar }, headers:, as: :json)

    assert_response :bad_request
  end

  test "create, with missing signiture" do
    post(stripe_events_path, params: event_params)

    assert_response :bad_request
  end

  test "create, with with invalid signiture" do
    post(stripe_events_path, params: event_params, headers: { "HTTP_STRIPE_SIGNATURE" => "invalid" }, as: :json)

    assert_response :bad_request
  end

  def headers = { "HTTP_STRIPE_SIGNATURE" => generate_stripe_event_signature }

  def event_params
    file_path = "test/fixtures/stripe_events/customer.subscription.created.json"

    JSON.parse(File.read(file_path))
  end

  def generate_stripe_event_signature
    secret = ENV.fetch("STRIPE_ENDPOINT_SECRET")
    time = Time.current
    signature = Stripe::Webhook::Signature.compute_signature(time, event_params.to_json, secret)

    Stripe::Webhook::Signature.generate_header(time, signature)
  end
end
