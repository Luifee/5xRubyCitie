class Api::V1::UtilsController < ApplicationController

  def subscribe
    email = params['subscribe']['email']
    sub = Subscribe.new(email: email)

    if sub.save
      render json: { status: 'ok', email: email }
    else
      render json: { status: 'duplicated', email: email }
    end
  end

  def cart
    product = Product.joins(:skus).find_by(skus: { id: params[:sku]})

    if product
    current_cart.add_sku(params[:sku])

    session[:cart_temp] = current_cart.serialize

    render json: { status: 'added', items: current_cart.items.count }
    end
  end

  private

  def find_product
    product = Product.friendly.find(params[:id])
  end

end
