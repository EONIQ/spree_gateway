Spree::PaymentMethod.class_eval do
  after_update :update_stripe_api_key, if: :stripe_payment_method?

  def stripe_payment_method?
    method_type == 'stripegateway'
  end

  def update_stripe_api_key
    Stripe.api_key = Spree::PaymentMethod.where(type: 'Spree::Gateway::StripeGateway').first.try(:preferred_secret_key)
  end
end