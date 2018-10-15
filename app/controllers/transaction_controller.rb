
class TransactionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @base = Transbank::Onepay::Base::DEFAULT_CALLBACK
  end

  def create
    Transbank::Onepay::Base.shared_secret = "?XW#WOLG##FBAGEAYSNQ5APD#JF@$AYZ"
    Transbank::Onepay::Base.api_key = "dKVhq1WGt_XapIYirTXNyUKoWTDFfxaEV63-O5jcsdw"

   # ENV["ONEPAY_API_KEY"] = "mUc0GxYGor6X8u-_oB3e-HWJulRG01WoC96-_tUA3Bg"
    Transbank::Onepay::Base.integration_type = 'TEST'
    sample_data = JSON.parse '{"items":[{"amount":36000,"quantity": 1,"description":"Fresh Strawberries"},{"amount":16000,"quantity":1,"description":"Lightweight Jacket"}]}'
    cart = Transbank::Onepay::ShoppingCart.new sample_data['items']
    @transaction_creation_response = Transbank::Onepay::Transaction.create(shopping_cart: cart).to_h

    render json: {
        responseCode: @transaction_creation_response["response_code"],
        description: @transaction_creation_response["description"],
        occ: @transaction_creation_response["occ"],
        ott: @transaction_creation_response["ott"],
        externalUniqueNumber: @transaction_creation_response["external_unique_number"],
        qrCodeAsBase64: @transaction_creation_response["qr_code_as_base64"],
        issuedAt: @transaction_creation_response["issued_at"],
        signature: @transaction_creation_response["signature"],
        amount: cart.total
    }
  end

  def commit
    @status = params[:status]
    @occ = params[:occ]
    @external_unique_number = params[:externalUniqueNumber]

    if @status && @status != 'PRE_AUTHORIZED'
      return render json: {message: 'Error while committing', occ: @occ, external_unique_number: @external_unique_number}, status: 403
    end

    @transaction_commit_response = Transbank::Onepay::Transaction.commit(@occ, @external_unique_number)
  end

  def refund

  end

  # {"response_code":"OK",
  #  "description":"OK",
  #  "occ":"1810911173917367",
  #  "ott":36361820,
  #  "external_unique_number":"1539358627395",
  #  "qr_code_as_base64":"iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAADmUlEQVR42u3dQY7CMBBFQd//0uEELJBMun93PWl2iIHYxcKK4/NI+tpxCSRAJEAkQCRAJEAkQCRAJEAkQCQBIgEiASIBIgEiASIBIgEiASIBIgkQCRAJEAkQaQuQc07E36+fP+X128YLEEAAAQQQQAABBBBAAAEEEEAAAeTuBS9burv0eaZOmKnjBQggxgsQQAABBBBAAAEEEEAAAQSQu18wZdn23xO46n3SxwsQQAABBBBAAAEEEEAAAQQQQAABBJA3Pw8ggAACCCCAAAIIIIAAAggggAACCCCAvD9A25aFAQEEEEAAAQQQQAABBBBAAAEEEEBmA0n/POkTw5ZbQAAxXoAAYrwAAcR4AQIIIIAAAgggjj/Ifb3jDwABBBBATHhAAAEEEEAAAQQQQACZDWRb6Yd4ChBABAggAgQQQAABBBBAAAFkJ5Buy33py6RVkP/9fTv+IAACCCCAAAIIIIAAAggggAACCCCbgNy6sFXvUwWwG5CNy8uAAAIIIIAAAggggAACCCCAAAIIIPkTcvJW04ofOkAAAQQQQAABBBBAAAEEEEAAAQSQWiBTlzG7TYyUYwvcrAgIIIAAAggggAACCCCAAAIIIIDsBNJt627Klt6U97fMCwgggAACCCCAAAIIIIAAAggggMzYcjsVsh+c5Yd4AgIIIIAAAggggAACCCCAAAIIIM2BpP/f9Jv0tt3kCQgggAACCCCAAAIIIIAAAggggAByd6C7TeyUQ0jTl8EBAQQQQAABBBBAAAEEEEAAAQQQQJ6Wz6LvtkW0G/z0Yxo8OA4QQAABBBBAAAEEEEAAAQQQQACZASQdbLfl1qnHTAACCCCAAAIIIIAAAggggAACCCCA9BzQbTcNpiyrenAcIIAAAggggAACCCCAAAIIIIAAMhvItmXbqgespUC2zAsIIIAAAggggAACCCCAAAIIIIBkAem25bPbxEjZctvxQXCAAAIIIIAAAggggAACCCCAAAIIIHOBpEyAlOuTBA0QQAABBBBAAAEEEEAAAQQQQAABJB9IOoSqCZ9ynQEBBBBAAAEEEEAAAQQQQAABBBBAsrbcpky8lJsDk25iBAQQQAABBBBAAAEEEEAAAQQQQADJOf4gZQKn3LTpZkVAAAEEEEAAAQQQQAABBBBAAAGkJxApNUAkQCRAJEAkQCRAJEAkQCRAJEAkASIBIgEiASIBIgEiASIBIgEiASIJEAkQCRAJEKlDH6PVj2ZD2ib1AAAAAElFTkSuQmCC",
  #  "issued_at":1539358822,
  #  "signature":"UtP00V9VCZQIU6igOA8pN7b6VXQQDIiHDoFzHxm3hho="}

end

