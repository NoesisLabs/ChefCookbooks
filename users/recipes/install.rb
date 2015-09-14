node[:users].each do |username, password|
  user "#{username}" do
    password "#{password}"
  end
end