powershell_script 'Install Chocolatey' do
  code "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
  convert_boolean_return true
  guard_interpreter :powershell_script
  not_if "Try{& $env:CHOCOLATEYINSTALL\\choco.exe -h; Return $TRUE;}Catch{Return $FALSE;}"
end