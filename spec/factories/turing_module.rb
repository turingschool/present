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
