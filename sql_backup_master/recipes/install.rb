require 'win32/service'

powershell_script 'install sql backup master' do
  code <<-EOH
  wget "#{node[:sqlBackupMaster][:url]}" -OutFile "$env:TEMP\\sqlbackupmaster.exe"
  & $env:TEMP\\sqlbackupmaster.exe /quiet
  EOH
  action :run
  not_if do ::Win32::Service.exists?('SQL Backup Master') end
end