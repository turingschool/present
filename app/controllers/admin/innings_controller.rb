class Admin::InningsController < Admin::BaseController
  before_action :find_inning, only: [:edit, :update]
  
  def edit
  end

  def new
    @inning = Inning.new
  end

  def create
    @inning = Inning.new(inning_params)
    if @inning.save
      redirect_to admin_path
    else
      flash[:error] = @inning.errors.full_messages.to_sentence
      render :new
    end
  end
  
  def update
    @inning.update(inning_params)
    if @inning.save
      redirect_to admin_path
    else
      flash[:error] = @inning.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def inning_params
    params.require(:inning).permit(:name, :start_date)
  end

  def find_inning
    @inning = Inning.find(params[:id])
  end
end
