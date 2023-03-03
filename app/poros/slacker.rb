class Slacker
  attr_reader :name, :id
  
  def initialize(name, id)
    @name = name
    @id = id
  end

  def self.from_channel(data)
    new(data[:attributes][:name], data[:attributes][:slack_user_id])
  end
end