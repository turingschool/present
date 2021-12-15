FactoryBot.define do
  factory :turing_module do
    program { :FE }
    module_number { 3 }
    inning

    factory :frontend do
      program { :FE }

      factory :fe1 do
        module_number { 1 }
      end
    end
  end
end
