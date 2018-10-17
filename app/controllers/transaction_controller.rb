
class TransactionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @base = Transbank::Onepay::Base::DEFAULT_CALLBACK
  end

  def create
    sample_data = [
                  {amount:36000,quantity: 1,description:"Fresh Strawberries"},
                  {amount:16000,quantity:1,description:"Lightweight Jacket"}
                  ]
    cart = Transbank::Onepay::ShoppingCart.new sample_data
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

    @transaction_commit_response = Transbank::Onepay::Transaction.commit(occ: @occ, external_unique_number: @external_unique_number)
  end

  def refund
    amount = params[:amount]
    occ = params[:occ]
    external_unique_number = params[:external_unique_number]
    authorization_code = params[:authorization_code]

    refund_params = { amount: amount,
                      occ: occ,
                      external_unique_number: external_unique_number,
                      authorization_code: authorization_code }
    @refund_response = Transbank::Onepay::Refund.create(refund_params)
  rescue Transbank::Onepay::Errors::RefundCreateError => e
    return render json: { message: e.message }
  end


end

