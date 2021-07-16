class CartsController < ApplicationController

  before_action :authenticate_user!

  def show
  end

  def destroy
    session[:cart_temp] = nil
    redirect_to root_path, notice: '購物車已清空'
  end

end
