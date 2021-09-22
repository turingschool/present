class WelcomeController < ApplicationController
  def index
    @inning = Inning.last
  end
end
