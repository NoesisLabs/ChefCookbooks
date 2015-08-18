service 'ReportServer' do
  action [:start, :enable]
end

powershell_script "Configure SSRS" do
  code <<-EOH
  $rsConfig = Get-WmiObject -namespace "root\\Microsoft\\SqlServer\\ReportServer\\RS_MSSQLServer\\v12\\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost -filter "InstanceName='#{node[:ssrsdbsetup][:instance_name]}'"

  $rsConfig.RemoveURL("ReportServerWebService", "#{node[:ssrsconfig][:base_url]}", 1033);
  $rsConfig.RemoveURL("ReportManager", "#{node[:ssrsconfig][:base_url]}", 1033);

  $rsConfig.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033);
  $rsConfig.SetVirtualDirectory("ReportManager", "Reports", 1033);

  $rsConfig.ReserveURL("ReportServerWebService", "#{node[:ssrsconfig][:base_url]}", 1033);
  $rsConfig.ReserveURL("ReportManager", "#{node[:ssrsconfig][:base_url]}", 1033);

  $script = $rsConfig.GenerateDatabaseCreationScript("#{node[:ssrsconfig][:database_name]}", 1033, $FALSE)
  Invoke-Sqlcmd -Query $script -ServerInstance "#{node[:ssrsconfig][:instance_name]}"

  EOH
  action :run
end