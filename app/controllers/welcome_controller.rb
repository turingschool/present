class WelcomeController < ApplicationController
  def index
    @innings = Inning.all
  end
end
