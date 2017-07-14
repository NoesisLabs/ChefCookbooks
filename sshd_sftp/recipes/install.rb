# Setup User/Group/Directory structure
group node[:sshd_sftp][:group]

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
  variables({
    :group => node[:sshd_sftp][:group]
  })
end
