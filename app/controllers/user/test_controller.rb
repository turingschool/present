class User::TestController < ApplicationController
  def test
    WebsocketJob.perform_async
  end
end
