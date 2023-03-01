FactoryBot.define do
  factory :turing_module do
    program { :FE }
    module_number { 3 }
    inning

    factory :setup_module do
      module_number {2}
      program {:BE} 
      populi_course_id {10547831}

      after(:create) do |mod|
        create(:student, turing_module: mod, name: 'Leo BG# BE', populi_id: 24490130, zoom_id: 'JeeCl38JQ9aKoGcukftsqA', slack_id: "U013Y0T89V1")
        create(:student, turing_module: mod, name: 'Anthony B. (He/Him) BE 2210', populi_id: 24490140, zoom_id: '79rFGPQZTZyOW9VLTrbQJw', slack_id: "U035BQEGZ")
        create(:student, turing_module: mod, name: 'Lacey W (she/her)', populi_id: 24490100, zoom_id: "K67iqvCfTKG0YnK2EsPxDg", slack_id: "U0255B3MMB4")
        create(:student, turing_module: mod, name: 'Anhnhi T# BE', populi_id: 24490062, zoom_id: "wxO7hYNnQPWaiOxm8kplXw", slack_id: "U022NF3D4SV")
        create(:student, turing_module: mod, name: 'J Seymour (he/they) BE', populi_id: 24490161, zoom_id: "W7NlFRvdQF2lC8KGoYA28A", slack_id: "U02199TD8SC")
        create(:student, turing_module: mod, name: 'Samuel C (He/Him) BE', populi_id: 24490123, zoom_id: "nVbUQ8DrR5WFVjxEjwhJEg", slack_id: "U01CBJGFXRC")
      end
    end


    factory :frontend do
      program { :FE }

      factory :fe1 do
        module_number { 1 }
      end

      factory :fe2 do
        module_number { 2 }
      end

      factory :fe3 do
        module_number { 3 }
      end
    end

    factory :backend do
      program { :BE }

      factory :be1 do
        module_number { 1 }
      end

      factory :be2 do
        module_number { 2 }
      end

      factory :be3 do
        module_number { 3 }
      end
    end

    factory :m4 do
      program { :Combined }
      module_number { 4 }
    end
  end
end
