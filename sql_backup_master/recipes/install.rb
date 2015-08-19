require 'win32/service'

service_name = 'SQL Backup Master'

powershell_script 'install sql backup master' do
  code <<-EOH
  wget "#{node[:sqlbackupmaster][:url]}" -OutFile "$env:TEMP\\sqlbackupmaster.exe"
  & $env:TEMP\\sqlbackupmaster.exe /quiet
  EOH
  action :run
  not_if do ::Win32::Service.exists?(service_name) end
end

windows_service service_name do
  action [:start, :enable]
end