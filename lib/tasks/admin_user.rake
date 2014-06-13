
desc 'Create an admin user and roles for development environment'

def create_role_if_not_exists(name)
  role = Role.find_by(:name => name)
  return role unless role.nil?
  role = Role.new(:name => name)
  role.save
  role
end

task :admin_user => :environment do |t, args|
  admin = create_role_if_not_exists('admin')
  create_role_if_not_exists('archivist')
  create_role_if_not_exists('submitter')
  u = User.new({:email => "admin@example.org", :roles => [admin], :password => "admin123", :password_confirmation => "admin123" })
  u.save
end

