class PairsController < ApplicationController
  def index
    @my_module = current_user.my_module
    @pairs = Pair.all
  end

  def create
    pair = Pair.new(pair_params)
    if pair.save
      flash[:message] = 'Pairings created!'
      redirect_to pairs_path
    else
      flash[:error] = "#{pair.errors.full_messages.to_sentence}"
      render 'index'
    end
  end

  private

  def pair_params
    params.permit(:name, :size)
  end
end
