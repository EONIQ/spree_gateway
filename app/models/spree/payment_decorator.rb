Spree::Payment.class_eval do 
  self.send(:remove_const, :INVALID_STATES)
  INVALID_STATES      = %w(failed invalid disputed withdrawn).freeze

  scope :disputed, -> { with_states(['disputed', 'withdrawn']) }
  scope :completed, -> { with_states(['completed', 'reinstated']) }
  
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

    state :reinstated
    event :reinstate do
      transition from: [:disputed], to: :reinstated
    end

    state :withdrawn
    event :withdraw do
      transition from: [:disputed], to: :withdrawn
    end

    after_transition to: [:disputed, :reinstated, :withdrawn] do |payment, transition|
      payment.update_order
    end
  end

  def can_dispute?
    completed?
  end
end