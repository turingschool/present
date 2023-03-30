require 'rails_helper'

RSpec.describe ZoomMeeting do
  it {should have_many :zoom_aliases}
  it {should have_one :attendance}
end