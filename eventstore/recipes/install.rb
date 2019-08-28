require 'win32/service'

powershell_script 'install eventstore' do
  code <<-EOH
  Add-Type -assembly "system.io.compression.filesystem"
  wget "#{node[:eventstore][:url]}" -OutFile "$env:TEMP\\eventstore.zip"
  [io.compression.zipfile]::ExtractToDirectory("$env:TEMP\\eventstore.zip", "#{node[:eventstore][:destination_path]}")
  $choco = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\\choco.exe"
  & $choco install nssm --acceptlicense --yes --force
  $nssm = [Environment]::GetEnvironmentVariable("ChocolateyInstall", "Machine") + "\\bin\\nssm.exe"
  & $nssm install EventStore "#{node[:eventstore][:destination_path]}\\EventStore.ClusterNode.exe" --db ./db --log ./logs --reduce-file-cache-pressure TRUE
  EOH
  action :run
  not_if do ::Win32::Service.exists?('EventStore') end
end

windows_service 'EventStore' do
  action [:start, :enable]
end
