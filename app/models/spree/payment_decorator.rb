Spree::Payment.class_eval do 
  self.send(:remove_const, :INVALID_STATES)
  INVALID_STATES      = %w(failed invalid disputed).freeze

  scope :disputed, -> { with_state('disputed') }
  
  # Redefine state 
  state_machine initial: :checkout do
    state :disputed
    event :dispute do
      transition from: [:completed], to: :disputed
    end

    after_transition to: :disputed do |payment, transition|
      payment.order.updater.update
    end
  end

  def can_dispute?
    completed?
  end
end