service_name = "OctopusDeploy Tentacle: #{node[:octopusdeploy][:tentacle_name]}"

powershell_script 'Install Octopus Tentacle' do
  code <<-EOH
  $choco = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\\choco.exe"
  & $choco install octopusdeploy.tentacle --acceptlicense --yes --force
  EOH
  action :run
  not_if do ::Win32::Service.exists?(service_name) end
end

batch 'Configure Octopus Tentacle' do
  code <<-EOH
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" create-instance --instance "#{node[:octopusdeploy][:tentacle_name]}" --config "#{node[:octopusdeploy][:root_path]}\Tentacle.config" --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" new-certificate --instance "#{node[:octopusdeploy][:tentacle_name]}" --if-blank --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" configure --instance "#{node[:octopusdeploy][:tentacle_name]}" --reset-trust --console
  "%PROGRAMFILES%\\Octopus Deploy\\Tentacle\\tentacle.exe" configure --instance "#{node[:octopusdeploy][:tentacle_name]}" --home "#{node[:octopusdeploy][:root_path]}" --app "#{node[:octopusdeploy][:root_path]}\Applications" --port "10933" --console
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