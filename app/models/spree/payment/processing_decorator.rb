Spree::Payment::Processing.module_eval do 
  def cancel!
    if !disputed?
      response = payment_method.cancel(response_code)
      handle_response(response, :void, :failure)
    end
  end
end