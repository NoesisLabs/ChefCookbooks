powershell_script 'Install IIS' do
  code <<- EOH
  Add-WindowsFeature Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Redirect, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering, Web-Basic-Auth, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-WebSockets, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Mgmt-Service
  EOH
  action :run
  not_if "(Get-WindowsFeature -Name Web-Server).Installed"
end

windows_service 'w3svc' do
  action [:start, :enable]
end