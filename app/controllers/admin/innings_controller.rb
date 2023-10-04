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
      InningRolloverJob.perform_at(@inning.start_date.to_time, @inning.id)
      redirect_to admin_path
    else
      flash[:error] = @inning.errors.full_messages.to_sentence
      render :new
    end
  end
  
  def update
    @inning.update(inning_params)
    if @inning.save
      if inning_params[:start_date].nil? # if start_date is unchanged, dnot reschedule job
        redirect_to admin_path
      else
        reschedule_job(@inning)
        redirect_to admin_path
      end
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

  def reschedule_job(inning)
    jobs = Sidekiq::ScheduledSet.new
    jobs.find do |job|
      job.item["args"] == [inning.id] && job.display_class == "InningRolloverJob"
    end.delete
    InningRolloverJob.perform_at(inning.start_date.to_time, inning.id)
  end
end
