require 'win32/service'

powershell_script "Create SSRS Database" do
  code <<-EOH
  $rsConfig = Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_MSSQLServer\v12\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost -filter "InstanceName='#{node[:ssrsdbsetup][:instance_name]}'"
  $script = $rsConfig.GenerateDatabaseCreationScript("#{node[:ssrsdbsetup][:database_name]}", 1033, $FALSE)
  Invoke-Sqlcmd -Query $script -ServerInstance "#{node[:ssrsdbsetup][:instance_name]}"
  EOH
  action :run
end