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
    product = Product.friendly.find(params[:id])

    if product
    cart = Cart.load_session(session[:cart_temp])
    cart.add_item(product.code)

    session[:cart_temp] = cart.serialize

    render json: { status: 'added', items: cart.items.count }
    end
  end

  private

  def find_product
    product = Product.friendly.find(params[:id])
  end

end
