require "stripe"
require "stripe_event"

Stripe.api_key = Spree::PaymentMethod.where(type: 'Spree::Gateway::StripeGateway').first.try(:preferred_secret_key)

StripeEvent.configure do |events|
  events.subscribe 'charge.dispute.created' do |event|
    Spree::Payment.where(response_code: event.data.object.charge).all.collect(&:dispute)
  end
  events.subscribe 'charge.dispute.funds_reinstated' do |event|
    Spree::Payment.where(response_code: event.data.object.charge).all.collect(&:reinstate)
  end
  events.subscribe 'charge.dispute.funds_withdrawn' do |event|
    Spree::Payment.where(response_code: event.data.object.charge).all.collect(&:withdraw)
  end
end