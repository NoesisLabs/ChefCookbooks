#
# Cookbook Name:: mirthconnect
# Recipe:: install
#
# Copyright 2014, Diagnotes, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Modified by Noesis Labs

# Install Dependencies

execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    !File.exists?('/var/lib/apt/periodic/update-success-stamp') ||
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

package "default-jdk"


# Setup User/Group/Directory structure
group node[:mirthconnect][:group]

user node[:mirthconnect][:user] do
  supports :manage_home => true
  gid node[:mirthconnect][:group]
  comment "Mirth Connect"
  home node[:mirthconnect][:homedir]
  shell "/bin/bash"
end

directory node[:mirthconnect][:homedir] do
  owner node[:mirthconnect][:user]
  group node[:mirthconnect][:group]
  recursive true
  mode 00700
end


# Download and setup Mirth
downloaded_archive = "Chef::Config['file_cache_path']/mirthconnect-#{node[:mirthconnect][:version]}-unix.tar.gz"
remote_file downloaded_archive do
  user node[:mirthconnect][:user]
  source "http://downloads.mirthcorp.com/connect/#{node[:mirthconnect][:version]}/mirthconnect-#{node[:mirthconnect][:version]}-unix.tar.gz"
  not_if { File.exists? downloaded_archive }
end

bash "install-mirth" do
  cwd Chef::Config['file_cache_path']
  code <<-EOL
  tar xzf #{downloaded_archive}
  mv Mirth\ Connect/ #{node[:mirthconnect][:homedir]}
  EOL
  not_if { File.exists? downloaded_archive }
end

template "#{node[:mirthconnect][:homedir]}/conf/mirth.properties" do
  source "mirth.properties.erb"
  mode 0600
  owner node[:mirthconnect][:user]
  group "root"
  variables({
    :appdatadir => node[:mirthconnect][:appdatadir],
    :dbtype => node[:mirthconnect][:dbtype],
    :dburl => node[:mirthconnect][:dburl],
    :dbuser => node[:mirthconnect][:dbuser],
    :dbpassword => node[:mirthconnect][:dbpassword],
	:httpport => node[:mirthconnect][:httpport],
	:httpsport => node[:mirthconnect][:httpsport]
  })
end

systemd_unit 'mirthconnect.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=MirthConnect
  After=network.target

  [Service]
  Type=forking

  User=node[:mirthconnect][:user]
  Group=node[:mirthconnect][:group]
  ExecStart=/opt/mirthconnect/mcservice start
  ExecStop=/opt/mirthconnect/mcservice stop
  ExecRestart=/opt/mirthconnect/mcservice restart

  TimeoutSec=60

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end
