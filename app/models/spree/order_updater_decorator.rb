Spree::OrderUpdater.class_eval do 
  # Add disputed to payemnt state
  # Updates the +payment_state+ attribute according to the following logic:
  #
  # paid          when +payment_total+ is equal to +total+
  # balance_due   when +payment_total+ is less than +total+
  # credit_owed   when +payment_total+ is greater than +total+
  # failed        when most recent payment is in the failed state
  # void          when order is canceled and +payment_total+ is equal to zero
  # disputed      when +payment_total+ is less than +total+ and one of the payment is disputed
  #
  # The +payment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
  def update_payment_state
    last_state = order.payment_state
    if order.outstanding_balance > 0 && payments.present? && payments.disputed.size > 0
      order.payment_state = 'disputed'
    elsif payments.present? && payments.valid.size == 0
      order.payment_state = 'failed'
    elsif order.canceled? && order.payment_total == 0
      order.payment_state = 'void'
    else
      order.payment_state = 'balance_due' if order.outstanding_balance > 0
      order.payment_state = 'credit_owed' if order.outstanding_balance < 0
      order.payment_state = 'paid' if !order.outstanding_balance?
    end
    order.state_changed('payment') if last_state != order.payment_state
    order.payment_state
  end
end