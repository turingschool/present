class PairsController < ApplicationController
  def index
    @my_module = current_user.my_module
  end

  def create
    pair = Pair.new(params)
    if pair.save
      flash[:message] = 'Pairings created!'
    else
      flash[:error] = "#{pair.errors.full_messages.to_sentence}"
    end
  end
end
