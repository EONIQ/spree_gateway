Spree::Payment.class_eval do 
  self.send(:remove_const, :INVALID_STATES)
  INVALID_STATES      = %w(failed invalid disputed).freeze

  scope :disputed, -> { with_state('disputed') }
  scope :reinstated, -> { with_state('reinstated') }
  
  # Redefine state 
  state_machine initial: :checkout do
    state :disputed, :reinstated
    event :dispute do
      transition from: [:completed], to: :disputed
    end
    event :reinstate do 
      transition from: [:disputed], to: :reinstated
    end

    after_transition to: :disputed do |payment, transition|
      payment.order.updater.update
    end
  end

  def can_dispute?
    completed?
  end
end