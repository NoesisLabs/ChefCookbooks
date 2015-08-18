data_path = "#{node[:mssql][:root_path]}\\Data"
log_path = "#{node[:mssql][:root_path]}\\Logs"
backup_path = "#{node[:mssql][:root_path]}\\Backups"

["#{data_path}", "#{log_path}", "#{backup_path}"].each do |path|
  directory path do
    recursive true
	action :create
  end
end

registry_key "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\#{node[:mssql][:service_name]}\\MSSQLServer" do
  values [{:name => "DefaultData", :type => :string, :data => "#{data_path}"},
          {:name => "DefaultLog", :type => :string, :data => "#{log_path}"},
		  {:name => "BackupDirectory", :type => :string, :data => "#{backup_path}"}
         ]
  action :create
end

powershell_script "Restart MS SQL and dependendant services" do
  code <<-EOH
  restart-service "#{node[:mssql][:service_name]}" -force -passthru
  EOH
  action :run
end