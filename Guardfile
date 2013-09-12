guard 'rspec', :cli => '--color --format documentation', :env => {'SPRING_TMP_PATH' => "/tmp"}, :spring => true do
  watch('config/routes.rb')
  watch(%r{^spec/.+_spec.rb$})
  watch(%r{^lib/(.+).rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
  ignore(/jetty/)

  # Rails
  watch(%r{^app/(.+).rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(.erb|.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller).rb$})  { |m| %W(spec/routing/#{m[1]}_routing_spec.rb spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb spec/acceptance/#{m[1]}_spec.rb) }
  watch(%r{^spec/support/(.+).rb$})                  { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*.(erb|haml)$})          { |m| "spec/features/#{m[1]}_spec.rb" }
end