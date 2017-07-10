Spree::Order.class_eval do
  # Redefine Payment States
  # self.send(:remove_const, :PAYMENT_STATES)
  PAYMENT_STATES = %w(balance_due credit_owed failed paid void disputed)

  # Reset validator for payment state
  _validators.delete(:payment_state)
  _validate_callbacks.each do |callback|
    if callback.raw_filter.respond_to? :attributes
      callback.raw_filter.attributes.delete :payment_state
    end
  end
  validates :payment_state,   inclusion: { in: PAYMENT_STATES, allow_blank: true }
end