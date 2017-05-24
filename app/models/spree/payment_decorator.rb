Spree::Payment.class_eval do 
  self.send(:remove_const, :INVALID_STATES)
  INVALID_STATES      = %w(failed invalid disputed withdrawn).freeze

  scope :disputed, -> { with_state(['disputed', 'withdrawn']) }
  scope :completed, -> { with_state(['completed', 'reinstated']) }

  # Redefine state 
  state_machine initial: :checkout do
    state :disputed
    event :dispute do
      transition from: [:completed], to: :disputed
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
end