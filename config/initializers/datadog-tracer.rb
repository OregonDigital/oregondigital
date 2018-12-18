# frozen_string_literal: true

if %w[production staging].include? Rails.env
  Datadog.configure do |c|
    c.use :rails, service_name: "oregon-digital-#{Rails.env}"
    c.use :http, service_name: "oregon-digital-#{Rails.env}-http"
    c.use :resque, service_name: "oregon-digital-#{Rails.env}-resque"
  end
end
