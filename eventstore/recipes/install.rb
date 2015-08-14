powershell_script 'install eventstore' do
  code <<-EOH
  Add-Type -assembly "system.io.compression.filesystem"
  wget "#{node[:eventstore][:url]}" -OutFile "%TEMP%\\eventstore.zip"
  [io.compression.zipfile]::ExtractToDirectory("%TEMP%\\eventstore.zip", "#{node[:eventstore][:destination_path]}")
  choco install nssm --acceptlicense --yes --force
  nssm install EventStore "#{node[:eventstore][:destination_path]}\\EventStore.ClusterNode.exe" --db ./db --log ./logs
  EOH
  action :run
end