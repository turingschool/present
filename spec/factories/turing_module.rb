FactoryBot.define do
  factory :turing_module do
    program { :FE }
    module_number { 3 }
    inning

    factory :setup_module do
      module_number {3}
      program {:BE} 
      populi_course_id {10547831}

      after(:create) do |mod|
        student1 = create(:setup_student, turing_module: mod, name: 'Leo Banos Garcia', populi_id: 24490130, slack_id: "U013Y0T89V1")
        student2 = create(:setup_student, turing_module: mod, name: 'Anthony Blackwell Tallent', populi_id: 24490140, slack_id: "U035BQEGZ")
        student3 = create(:setup_student, turing_module: mod, name: 'Lacey Weaver', populi_id: 24490100, slack_id: "U0255B3MMB4")
        student4 = create(:setup_student, turing_module: mod, name: 'Anhnhi Tran', populi_id: 24490062, slack_id: "U022NF3D4SV")
        student5 = create(:setup_student, turing_module: mod, name: 'J Seymour', populi_id: 24490161, slack_id: "U02199TD8SC")
        student6 = create(:setup_student, turing_module: mod, name: 'Samuel Cox', populi_id: 24490123, slack_id: "U01CBJGFXRC")
        
        create(:zoom_alias, student: student1, name: 'Leo BG# BE', turing_module: mod)
        create(:zoom_alias, student: student2, name: "Anthony B. (He/Him) BE 2210", turing_module: mod)
        create(:zoom_alias, student: student3, name: "Lacey W (she/her)", turing_module: mod)
        create(:zoom_alias, student: student4, name: "Anhnhi T# BE", turing_module: mod)
        create(:zoom_alias, student: student5, name: "J Seymour (he/they) BE", turing_module: mod)
        create(:zoom_alias, student: student6, name: "Samuel C (He/Him) BE", turing_module: mod)
      end
    end
    
    factory :setup_module_no_aliases do
      module_number {3}
      program {:BE} 
      populi_course_id {10547831}

      after(:create) do |mod|
        create(:setup_student, turing_module: mod, name: 'Leo Banos Garcia', populi_id: 24490130, slack_id: "U013Y0T89V1")
        create(:setup_student, turing_module: mod, name: 'Anthony Blackwell Tallent', populi_id: 24490140, slack_id: "U035BQEGZ")
        create(:setup_student, turing_module: mod, name: 'Lacey Weaver', populi_id: 24490100, slack_id: "U0255B3MMB4")
        create(:setup_student, turing_module: mod, name: 'Anhnhi Tran', populi_id: 24490062, slack_id: "U022NF3D4SV")
        create(:setup_student, turing_module: mod, name: 'J Seymour', populi_id: 24490161, slack_id: "U02199TD8SC")
        create(:setup_student, turing_module: mod, name: 'Samuel Cox', populi_id: 24490123, slack_id: "U01CBJGFXRC")
      end
    end
  end
end
