inning = Inning.create!(name: "2203", current: true)

mod4 = inning.turing_modules.create!(program: 'Combined', module_number: 4)
fe1 = inning.turing_modules.create!(program: 'FE', module_number: 1)
fe2 = inning.turing_modules.create!(program: 'FE', module_number: 2)
fe3 = inning.turing_modules.create!(program: 'FE', module_number: 3)
be1 = inning.turing_modules.create!(program: 'BE', module_number: 1)
be2 = inning.turing_modules.create!(program: 'BE', module_number: 2)
be3 = inning.turing_modules.create!(program: 'BE', module_number: 3)