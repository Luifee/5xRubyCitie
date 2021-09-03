class OrdersController < ApplicationController

  before_action :authenticate_user!
  before_action :find_order, only: [:cancel, :pay, :pay_confirm, :show]

  def index
    @orders = current_user.orders.order(created_at: :desc).take(10)
  end

  def create
    @order = current_user.orders.build(order_params)

    current_cart.items.each do |item|
      @order.order_items.build(sku_id: item.sku_id, quantity: item.quantity)
    end

    if @order.save
      prods = []
      @order.order_items.each do |list|
        pack = { name: list.name, quantity: list.quantity, price: list.total_price.to_i }
        prods << pack
      end

      linepay = LineAuthService.new(ENV['line_pay_uri'])
      linepay.execute({
	amount: current_cart.total_price.to_i, currency: "TWD", orderId: @order.num,
        packages:[{
          id: @order.num, amount: current_cart.total_price.to_i, products: prods
	}],
        redirectUrls:{
          confirmUrl: "https://localhost:3000/orders/confirm",
          cancelUrl: "https://localhost:3000/orders/cancel"
        }
      })

      if linepay.success?
        redirect_to linepay.payment_url
      else
	redirect_to '/cart/checkout', notice: '交易中斷，錯誤訊息：' + @result["returnCode"]
      end
    end
  end

  def confirm
    linepay = LineAuthService.new("/v3/payments/#{params[:transactionId]}/confirm")
    linepay.execute({amount: current_cart.total_price.to_i, currency: "TWD"})

    if linepay.success?
      order_id = params[:orderId]
      transaction_id = params[:transactionId]
      # 變更order狀態
      order = current_user.orders.find_by(num: order_id)
      order.pay!(transaction_id: transaction_id)
      # 清空購物車
      session[:cart_temp] = nil

      redirect_to root_path, notice: '付款完成'
    else
      redirect_to '/cart/checkout', notice: "付款中斷，錯誤訊息：" + @result["returnCode"] + "，" + @result["returnMessage"]
    end
  end

  def show
    @order_items = @order.order_items.includes(:sku)
  end

  def cancel
    if @order.paid?
      linepay = LineAuthService.new("/v3/payments/#{@order.transaction_id}/refund")
      linepay.execute(nil)

      if linepay.success?
        @order.cancel!
        redirect_to orders_path, notice: "訂單編號： #{@order.num}已取消，並辦理退款。"
      else
        redirect_to orders_path, notice: "退款發生錯誤：" + @result["returnCode"] + "，" + result["returnMessage"]
      end
    else
      @order.cancel!
      redirect_to orders_path, notice: "訂單編號： #{@order.num}已取消"
    end
  end

  def pay
    linepay = LineAuthService.new(ENV['line_pay_uri'])
    prods = []
    @order.order_items.each do |list|
      pack = { name: list.name, quantity: list.quantity, price: list.total_price.to_i }
      prods << pack
    end

    linepay.execute({
      amount: @order.total_price.to_i, currency: "TWD", orderId: @order.num,
      packages:[{
        id: @order.num, amount: @order.total_price.to_i, products: prods
      }],
      redirectUrls:{
        confirmUrl: "https://localhost:3000/orders/#{@order.id}/pay_confirm",
        cancelUrl: "https://localhost:3000/orders/#{@order.id}/pay_cancel"
      }
    })

    if linepay.success?
      redirect_to linepay.payment_url
    else
      redirect_to orders_path, notice: '交易中斷，錯誤訊息：' + @result["returnCode"]
    end
  end

  def pay_confirm
    linepay = LineAuthService.new("/v3/payments/#{params[:transactionId]}/confirm")
    linepay.execute({amount: @order.total_price.to_i, currency: "TWD"})

    if linepay.success?
      transaction_id = params[:transactionId]
      # 變更order狀態
      @order.pay!(transaction_id: transaction_id)

      redirect_to orders_path, notice: '付款完成'
    else
      redirect_to orders_path, notice: "付款中斷，錯誤訊息：" + @result["returnCode"] + "，" + @result["returnMessage"]
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
