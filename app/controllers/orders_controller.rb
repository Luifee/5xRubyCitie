class OrdersController < ApplicationController

  before_action :authenticate_user!

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(sku_id: item.sku_id, quantity: item.quantity)
    end

    if @order.save
      nonce = SecureRandom.uuid + Time.now.to_i.to_s
      url = ENV['line_pay_server'] + ENV['line_pay_uri']
      prods = []
      @order.order_items.each do |list|
        pack = { name: list.name, quantity: list.quantity, price: list.price.to_i }
        prods << pack
      end

      resp = Faraday.post(url) do |req|
        req.headers['Content-Type'] = 'application/json'
	req.headers['X-LINE-ChannelId'] = ENV['line_pay_id']
	req.headers['X-LINE-Authorization-Nonce'] = nonce
	req.body = {
	  amount: current_cart.total_price.to_i, currency: "TWD", orderId: @order.num,
	  packages:[{
  	    id: @order.num, amount: current_cart.total_price.to_i, 
	    products: prods
	  }],
	  redirectUrls:{
	    confirmUrl: "https://localhost:3000/orders/confirm",
	    cancelUrl: "https://localhost:3000/orders/cancel"
	  }
	}.to_json
	req.headers['X-LINE-Authorization'] = Base64.encode64(OpenSSL::HMAC.digest("SHA256", ENV['line_pay_secret'], ENV['line_pay_secret'] + ENV['line_pay_uri'] + req.body + nonce)).gsub(/\n/,"")
      end

      result = JSON.parse(resp.body)

      if result["returnCode"] == "0000"
        payment_url = result["info"]["paymentUrl"]["web"]
	redirect_to payment_url
      else
	redirect_to '/cart/checkout'
	flash[:notice] = '交易中斷，錯誤訊息：' + result["returnCode"]
      end
    end
  end

  def confirm
    nonce = SecureRandom.uuid + Time.now.to_i.to_s
    uri = "/v3/payments/#{params[:transactionId]}/confirm"
    url = ENV['line_pay_server'] + uri
    resp = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_id']
      req.headers['X-LINE-Authorization-Nonce'] = nonce
      req.body = {
        amount: current_cart.total_price.to_i, currency: "TWD"
      }.to_json
      req.headers['X-LINE-Authorization'] = Base64.encode64(OpenSSL::HMAC.digest("SHA256", ENV['line_pay_secret'], ENV['line_pay_secret'] + uri + req.body + nonce)).gsub(/\n/,"")
    end
    
    result = JSON.parse(resp.body)

    if result["returnCode"] == "0000"
      order_id = result["info"]["orderId"]
      transaction_id = result["info"]["transactionId"]
      # 變更order狀態
      order = current_user.orders.find_by(num: order_id)
      order.pay!(transaction_id: transaction_id)
      # 清空購物車
      session[:cart_temp] = nil

      redirect_to root_path, notice: '付款完成'
    else
      redirect_to '/cart/checkout'
      flash[:notice] = '付款中斷，錯誤訊息：' + result["returnCode"] + "，" + result["returnMessage"]
    end
  end

  private

  def order_params
    params.require(:order).permit(:receipient, :tel, :address, :note)
  end

end
