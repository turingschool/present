class PopuliStudent
  attr_reader :name, :personid

  def initialize(name, personid = nil)
    @name = name
    @personid = personid
  end

  def self.from_populi(populi_data)
    name = full_name(populi_data[:first], populi_data[:last], populi_data[:preferred])
    new(name, populi_data[:personid])
  end

  def self.full_name(first, last, preferred)
    first = preferred if preferred
    "#{first} #{last}"
  end
end

