class OrdersController < ApplicationController
  def cart
    @cart_items = []
    @total = 0

    (session[:cart] || {}).each do |product_id, quantity|
      product = Product.find(product_id)
      @cart_items << { product: product, quantity: quantity }
      @total += product.price * quantity
    end
  end

  def new
    @total = calculate_total
    @order = Order.new
  end

  def create
    @total = calculate_total
    @order = Order.new(order_params.merge(total_amount: @total, status: "pending"))

    if @order.save
      response = Paytree::Mpesa::StkPush.call(
        phone_number: @order.phone_number,
        amount: @order.total_amount,
        reference: "ORDER-#{@order.id}"
      )

      if response.success?
        @order.update(checkout_request_id: response.data["CheckoutRequestID"])
        session[:cart] = {} # clear cart
        redirect_to @order, notice: "STK Push sent!"
      else
        @order.destroy
        flash.now[:alert] = "Payment failed: #{response.message}"
        render :new
      end
    else
      render :new
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:phone_number)
  end

  def calculate_total
    (session[:cart] || {}).sum do |product_id, quantity|
      Product.find(product_id).price * quantity
    end
  end
end
