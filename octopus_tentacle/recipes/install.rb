service_name = "OctopusDeploy Tentacle: #{node[:octopusdeploy][:tentacle_name]}"

batch "tentacle_configure" do
  code <<-EOH
  choco install octopusdeploy.tentacle --acceptlicense --yes --force
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" create-instance --instance "#{node[:octopusdeploy][:tentacle_name]}" --config "C:\Octopus\Tentacle.config" --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" new-certificate --instance "#{node[:octopusdeploy][:tentacle_name]}" --if-blank --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" configure --instance "#{node[:octopusdeploy][:tentacle_name]}" --reset-trust --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" configure --instance "#{node[:octopusdeploy][:tentacle_name]}" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" configure --instance "#{node[:octopusdeploy][:tentacle_name]}" --trust "#{node[:octopusdeploy][:server_thumbprint]}" --console
  "netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" service --instance "#{node[:octopusdeploy][:tentacle_name]}" --install --start --console
  EOH
  action :run
  not_if do ::Win32::Service.exists?(service_name) end
end

windows_service service_name do
  action [:start, :enable]
end