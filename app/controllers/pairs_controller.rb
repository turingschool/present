class PairsController < ApplicationController
  def index
    @my_module = current_user.my_module
  end
end
