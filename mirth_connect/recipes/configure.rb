directory node[:mirthconnect][:appdatadir] do
  owner node[:mirthconnect][:user]
  group node[:mirthconnect][:group]
  recursive true
  mode 00700
end