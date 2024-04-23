class PopuliCourse
  attr_reader :name, :id

  def initialize(course_data)
    @id = course_data[:course_offering_id]
    @name = "#{course_data[:abbrv]} - #{course_data[:name]}"
  end
end