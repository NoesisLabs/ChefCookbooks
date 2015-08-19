windows_service "#{node[:mssql][:service_name]}" do
  action [:start, :enable]
end

data_path = "#{node[:mssql][:root_path]}\\Data"
log_path = "#{node[:mssql][:root_path]}\\Logs"
backup_path = "#{node[:mssql][:root_path]}\\Backups"

key_path = "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Microsoft SQL Server\\#{node[:mssql][:registry_instance_id]}\\MSSQLServer"

isDataKeySet = registry_data_exists?(
  key_path,
  {:name => "DefaultData", :type => :string, :data => data_path},
  :machine
)

isLogKeySet = registry_data_exists?(
  key_path,
  {:name => "DefaultLog", :type => :string, :data => log_path},
  :machine
)

isBackupKeySet = registry_data_exists?(
  key_path,
  {:name => "BackupDirectory", :type => :string, :data => backup_path},
  :machine
)

if(!isDataKeySet || !isLogKeySet || !isBackupKeySet)
  [data_path, log_path, backup_path].each do |path|
    directory path do
      recursive true
      action :create
    end
  end
  
  registry_key "#{key_path}" do
    values [{:name => "DefaultData", :type => :string, :data => data_path},
            {:name => "DefaultLog", :type => :string, :data => log_path},
            {:name => "BackupDirectory", :type => :string, :data => backup_path}
           ]
    action :create
  end
  
  powershell_script "Restart MS SQL and dependendant services" do
    code <<-EOH
    restart-service "#{node[:mssql][:service_name]}" -force -passthru
    EOH
    action :run
  end
end