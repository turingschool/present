class User::PairsController < User::BaseController
  def index
    @my_module = current_user.my_module
    @pairs = Pair.all
  end

  def show
    @my_module = current_user.my_module
    @pair = Pair.find(params[:id])
  end

  def create
    pair = Pair.new(pair_params)
    if pair.save
      flash[:message] = 'Pairings created!'
      redirect_to pairs_path
    else
      flash[:error] = "#{pair.errors.full_messages.to_sentence}"
      redirect_to pairs_path
    end
  end

  private

  def pair_params
    params.permit(:name, :size)
  end
end
