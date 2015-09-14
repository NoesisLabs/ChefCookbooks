powershell_script 'Install SMTP' do
  code <<-EOH
  Add-WindowsFeature Smtp-Server, Web-Lgcy-Mgmt-Console
  EOH
  action :run
  not_if "(Get-WindowsFeature -Name Smtp-Server).Installed"
end

node[:smtp][:settings].each do |key, value|
  powershell_script "Configure SMTP Setting #{key}" do
    code <<-EOH
    $smtp = Get-WMIObject IISSMTPServerSetting -Namespace root/MicrosoftIISv2
	$smtp.#{key} = #{value}
	$smtp.put()
    EOH
    action :run
    not_if "(Get-WindowsFeature -Name Smtp-Server).Installed"
  end
end

windows_service 'SMTPSVC' do
  action [:start, :enable]
end