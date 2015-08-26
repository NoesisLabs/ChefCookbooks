powershell_script 'Install SSL Certificate' do
  code <<-EOH
  $file = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "chef-" + [System.Guid]::NewGuid())
  Try
    {
      [System.IO.File]::WriteAllBytes($file, [System.Convert]::FromBase64String("#{node[:ssl_cert][:base_64_cert]}"))
      $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($file, "#{node[:ssl_cert][:cert_password]}", "MachineKeySet,PersistKeySet")
      $cert.FriendlyName = "#{node[:ssl_cert][:cert_friendly_name]}"
      $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("#{node[:ssl_cert][:store_name]}", "#{node[:ssl_cert][:store_location]}")
      $store.Open("ReadWrite")
      $store.Add($cert)
      $store.Close()
    }
  Finally
    {
      [System.IO.File]::Delete($file)
    }
  EOH
  action :run
end
