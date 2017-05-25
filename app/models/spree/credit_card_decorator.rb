Spree::CreditCard.class_eval do 
  def actions
    %w{capture void credit dispute}
  end
end