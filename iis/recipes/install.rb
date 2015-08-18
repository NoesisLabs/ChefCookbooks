powershell_script 'Install IIS' do
  code 'Add-WindowsFeature Web-Server'
  not_if "(Get-WindowsFeature -Name Web-Server).Installed"
end

windows_service 'w3svc' do
  action [:start, :enable]
end