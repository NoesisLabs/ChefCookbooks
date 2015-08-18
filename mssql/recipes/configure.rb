require 'win32/service'

%w[ #{node[:mssql][:root_path]}\\Data #{node[:mssql][:root_path]}\\Logs #{node[:mssql][:root_path]}\\Backups ].each do |path|
  directory path do
    recursive true
	action :create
  end
end

powershell_script "Configure MS SQL" do
  code <<-EOH
  $script = @"
    USE [master]
    GO
     
    — Change default location for data files
    EXEC   xp_instance_regwrite
           N'HKEY_LOCAL_MACHINE',
           N'Software\\Microsoft\\MSSQLServer\\MSSQLServer',
           N'DefaultData',
           REG_SZ,
           N'#{node[:mssql][:root_path]}\\Data'
    GO
     
    — Change default location for log files
    EXEC   xp_instance_regwrite
           N'HKEY_LOCAL_MACHINE',
           N'Software\\Microsoft\\MSSQLServer\\MSSQLServer',
           N'DefaultLog',
           REG_SZ,
           N'#{node[:mssql][:root_path]}\\Logs'
    GO
     
    — Change default location for backups
    EXEC   xp_instance_regwrite
           N'HKEY_LOCAL_MACHINE',
           N'Software\\Microsoft\\MSSQLServer\\MSSQLServer',
           N'BackupDirectory',
           REG_SZ,
           N'#{node[:mssql][:root_path]}\\Backups'
    GO
  "
  Invoke-Sqlcmd -Query $script -ServerInstance "#{node[:mssql][:instance_name]}"

  EOH
  action :run
end

service '#{node[:mssql][:service_name]}' do
  action :restart
end


