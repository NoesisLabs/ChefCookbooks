powershell_script 'Install SSL Certificate' do
  code <<-EOH
  $certBytes = [System.Convert]::FromBase64String("#{node[:ssl_cert][:base_64_cert]}")
  $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certBytes, "#{node[:ssl_cert][:cert_password]}", "MachineKeySet,PersistKeySet")
  $cert.FriendlyName = "#{node[:ssl_cert][:cert_friendly_name]}"
  $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("#{node[:ssl_cert][:store_name]}", "#{node[:ssl_cert][:store_location]}")
  $store.Open("ReadWrite")
  $store.Add($cert)
  $store.Close()
  EOH
  action :run
  convert_boolean_return true
  guard_interpreter :powershell_script
  not_if <<-EOH
  $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("#{node[:ssl_cert][:store_name]}", "#{node[:ssl_cert][:store_location]}")
  $store.Open("ReadOnly")
  $certNames = $store.Certificates | Select FriendlyName
  $store.Close()
  Return ($certNames -contains "#{node[:ssl_cert][:cert_friendly_name]}")
  EOH
end

