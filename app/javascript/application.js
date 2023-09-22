// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "controllers"
import "custom/main"
import "custom/sortable"
import "custom/dashboard"
import "custom/student_show"
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
