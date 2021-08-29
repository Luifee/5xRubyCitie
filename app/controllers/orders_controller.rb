class OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :find_order, only: [:cancel, :pay, :pay_confirm, :show]

  def index
    @orders = current_user.orders.order(created_at: :desc).includes(:order_items).take(10)
  end

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(sku_id: item.sku_id, quantity: item.quantity)
    end

    if @order.save
      uri = ENV['line_pay_uri']
      url = ENV['line_pay_server'] + uri
      prods = []
      @order.order_items.each do |list|
        pack = { name: list.name, quantity: list.quantity, price: list.total_price.to_i }
        prods << pack
      end

      body = {
	amount: current_cart.total_price.to_i, currency: "TWD", orderId: @order.num,
        packages:[{
          id: @order.num, amount: current_cart.total_price.to_i, products: prods
	}],
        redirectUrls:{
          confirmUrl: "https://localhost:3000/orders/confirm",
          cancelUrl: "https://localhost:3000/orders/cancel"
        }
      }

      resp = line_auth(url, body, uri)

      result = JSON.parse(resp.body)

      if result["returnCode"] == "0000"
        payment_url = result["info"]["paymentUrl"]["web"]
	redirect_to payment_url
      else
	redirect_to '/cart/checkout', notice: '交易中斷，錯誤訊息：' + result["returnCode"]
      end
    end
  end

  def confirm
    uri = "/v3/payments/#{params[:transactionId]}/confirm"
    url = ENV['line_pay_server'] + uri
    body = {amount: current_cart.total_price.to_i, currency: "TWD"}

    resp = line_auth(url, body, uri)
	    
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
      redirect_to '/cart/checkout', notice: "付款中斷，錯誤訊息：" + result["returnCode"] + "，" + result["returnMessage"]
    end
  end

  def show
  end

  def cancel
    if @order.paid?
      uri = "/v3/payments/#{@order.transaction_id}/refund"
      url = ENV['line_pay_server'] + uri
      body = nil
      resp = line_auth(url, body, uri)

      result = JSON.parse(resp.body)

      if result["returnCode"] == "0000"
        @order.cancel!
        redirect_to orders_path, notice: "訂單編號： #{@order.num}已取消，並辦理退款。"
      else
        redirect_to orders_path, notice: "退款發生錯誤：" + result["returnCode"] + "，" + result["returnMessage"]
      end
    else
      @order.cancel!
      redirect_to orders_path, notice: "訂單編號： #{@order.num}已取消"
    end
  end

  def pay
    uri = ENV['line_pay_uri']
    url = ENV['line_pay_server'] + uri
    prods = []
    @order.order_items.each do |list|
      pack = { name: list.name, quantity: list.quantity, price: list.total_price.to_i }
      prods << pack
    end
    body = {
      amount: @order.total_price.to_i, currency: "TWD", orderId: @order.num,
      packages:[{
        id: @order.num, amount: @order.total_price.to_i, products: prods
      }],
      redirectUrls:{
        confirmUrl: "https://localhost:3000/orders/#{@order.id}/pay_confirm",
        cancelUrl: "https://localhost:3000/orders/#{@order.id}/pay_cancel"
      }
    }
    resp = line_auth(url, body, uri)

    result = JSON.parse(resp.body)

    if result["returnCode"] == "0000"
      payment_url = result["info"]["paymentUrl"]["web"]
      redirect_to payment_url
    else
      redirect_to orders_path, notice: '交易中斷，錯誤訊息：' + result["returnCode"]
    end
  end

  def pay_confirm
    uri = "/v3/payments/#{params[:transactionId]}/confirm"
    url = ENV['line_pay_server'] + uri
    body = {amount: @order.total_price.to_i, currency: "TWD"}
    resp = line_auth(url, body, uri)

    result = JSON.parse(resp.body)

    if result["returnCode"] == "0000"
      transaction_id = result["info"]["transactionId"]
      # 變更order狀態
      @order.pay!(transaction_id: transaction_id)

      redirect_to orders_path, notice: '付款完成'
    else
      redirect_to orders_path, notice: "付款中斷，錯誤訊息：" + result["returnCode"] + "，" + result["returnMessage"]
    end
  end

  def line_auth(url, body, uri)
    nonce = SecureRandom.uuid + Time.now.to_i.to_s
    Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_id']
      req.headers['X-LINE-Authorization-Nonce'] = nonce
      req.body = body.to_json
      req.headers['X-LINE-Authorization'] = Base64.encode64(OpenSSL::HMAC.digest("SHA256", ENV['line_pay_secret'], ENV['line_pay_secret'] + uri + req.body + nonce)).gsub(/\n/,"")
      end
  end

  private

  def order_params
    params.require(:order).permit(:receipient, :tel, :address, :note)
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end

end
