require 'win32/service'

data_path = "#{node[:mssql][:root_path]}\\Data"
log_path = "#{node[:mssql][:root_path]}\\Logs"
backup_path = "#{node[:mssql][:root_path]}\\Backups"

%w[ data_path log_path backup_path ].each do |path|
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
           N'#{data_path}'
    GO

    — Change default location for log files
    EXEC   xp_instance_regwrite
           N'HKEY_LOCAL_MACHINE',
           N'Software\\Microsoft\\MSSQLServer\\MSSQLServer',
           N'DefaultLog',
           REG_SZ,
           N'#{log_path}'
    GO

    — Change default location for backups
    EXEC   xp_instance_regwrite
           N'HKEY_LOCAL_MACHINE',
           N'Software\\Microsoft\\MSSQLServer\\MSSQLServer',
           N'BackupDirectory',
           REG_SZ,
           N'#{backup_path}'
    GO
  "
  Invoke-Sqlcmd -Query $script -ServerInstance "#{node[:mssql][:instance_name]}"

  EOH
  action :run
end

service '#{node[:mssql][:service_name]}' do
  action :restart
end


