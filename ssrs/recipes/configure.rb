windows_service 'ReportServer' do
  action [:start, :enable]
end

powershell_script "Configure SSRS" do
  code <<-EOH
  $rsConfig = Get-WmiObject -namespace "root\\Microsoft\\SqlServer\\ReportServer\\RS_MSSQLServer\\v12\\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost -filter "InstanceName='#{node[:ssrs][:instance_name]}'"
  
  if(!$rsConfig.IsInitialized)
  {
    $rsConfig.RemoveURL("ReportServerWebService", "#{node[:ssrs][:base_url]}", 1033)
    $rsConfig.RemoveURL("ReportManager", "#{node[:ssrs][:base_url]}", 1033)
    
    $rsConfig.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033)
    $rsConfig.SetVirtualDirectory("ReportManager", "Reports", 1033)
    
    $rsConfig.ReserveURL("ReportServerWebService", "#{node[:ssrs][:base_url]}", 1033)
    $rsConfig.ReserveURL("ReportManager", "#{node[:ssrs][:base_url]}", 1033)
  }
  
  EOH
  action :run
end