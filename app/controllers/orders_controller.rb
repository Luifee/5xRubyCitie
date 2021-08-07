class OrdersController < ApplicationController

  before_action :authenticate_user!

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(sku_id: item.sku_id, quantity: item.quantity)
    end

    if @order.save
      nonce = SecureRandom.uuid + Time.now.to_i.to_s
      resp = Faraday.post("#{ENV['line_pay_server']}" + "#{ENV['line_pay_uri']}") do |req|
        req.headers['Content-Type'] = 'application/json'
	req.headers['X-LINE-ChannelId'] = ENV['line_pay_id']
	req.headers['X-LINE-Authorization-Nonce'] = nonce
	req.body = {
	  amount: current_cart.total_price.to_i, currency: "TWD", orderId: @order.num,
	  packages:[{
  	    id: "包裹編號", amount: current_cart.total_price.to_i, 
	    products:[{
	      name: "產品名稱", quantity: "購買數量", price: current_cart.total_price.to_i
	    }]
	  }],
	  redirectUrls:{
	    confirmUrl: "#{ENV['line_pay_confirmUrl']}",
	    cancelUrl: "#{ENV['line_pay_cancelUrl']}"
	  }
	}.to_json
	req.headers['X-LINE-Authorization'] = Base64.encode64(OpenSSL::HMAC.digest("SHA256", ENV['line_pay_secret'], ENV['line_pay_secret'] + ENV['line_pay_uri'] + req.body + nonce)).gsub(/\n/,"")
      end

      result = JSON.parse(resp.body)

      if result["returnCode"] == "0000"
        payment_url = result["info"]["paymentUrl"]["web"]
	redirect_to payment_url
      else
        flash[:notice] = '交易中斷，錯誤訊息：' + result["returnCode"]
	render 'carts/checkout'
      end
    end
  end

  private

  def order_params
    params.require(:order).permit(:receipient, :tel, :address, :note)
  end

end
