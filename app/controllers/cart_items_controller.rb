class CartItemsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    session[:cart] ||= {}
    session[:cart][product.id.to_s] ||= 0
    session[:cart][product.id.to_s] += 1
    redirect_to products_path, notice: "#{product.name} added to cart."
  end

  def destroy
    session[:cart].delete(params[:id])
    redirect_to cart_path, notice: "Item removed."
  end
end
