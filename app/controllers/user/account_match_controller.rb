class User::AccountMatchController < ApplicationController
    def new 
      
      report = ZoomService.participant_report(params[:zoom_meeting_id])
      binding.pry

    end 
end 