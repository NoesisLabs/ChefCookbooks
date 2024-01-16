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

# Download and setup Mirth

downloaded_archive = "#{Chef::Config['file_cache_path']}/mirthconnect-#{node[:mirthconnect][:version]}-unix.tar.gz"
remote_file downloaded_archive do
  source "https://s3.us-east-1.amazonaws.com/downloads.mirthcorp.com/connect/#{node[:mirthconnect][:version]}/mirthconnect-#{node[:mirthconnect][:version]}-unix.tar.gz"
  action :create_if_missing
end

execute "extract mirth" do
 user "root"
 group "root"
 command "tar xvzf #{downloaded_archive} -C /tmp"
end

execute "install mirth" do
 user "root"
 group "root"
 command "mv -n /tmp/Mirth\\ Connect/ #{node[:mirthconnect][:installdir]}"
end

directory node[:mirthconnect][:appdatadir] do
  user "root"
  group "root"
  recursive true
  mode 00700
end

template "#{node[:mirthconnect][:installdir]}/conf/mirth.properties" do
  user "root"
  group "root"
  source "mirth.properties.erb"
  mode 0600
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
  
  User=root
  Group=root
  ExecStart=#{node[:mirthconnect][:installdir]}/mcservice start
  ExecStop=#{node[:mirthconnect][:installdir]}/mcservice stop
  ExecReload=#{node[:mirthconnect][:installdir]}/mcservice restart

  TimeoutSec=60

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end
