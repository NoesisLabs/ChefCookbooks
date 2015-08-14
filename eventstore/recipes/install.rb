powershell_script 'install eventstore' do
  code <<-EOH
  Add-Type -assembly "system.io.compression.filesystem"
  wget "#{node[:evenstore][:url]}" -OutFile "%TEMP%\\eventstore.zip"
  [io.compression.zipfile]::ExtractToDirectory("%TEMP%\\eventstore.zip", "#{node[:evenstore][:destination_path]}")
  choco install nssm --acceptlicense --yes --force
  nssm install EventStore "#{node[:evenstore][:destination_path]}\\EventStore.ClusterNode.exe" --db ./db --log ./logs
  EOH
  action :run
end