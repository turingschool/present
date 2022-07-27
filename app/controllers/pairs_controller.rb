class PairsController < ApplicationController
  def index
    @my_module = current_user.my_module
    @pairs = Pair.all
  end

  def show
    @my_module = current_user.my_module
    @pair = Pair.find(params[:id])
  end
end
