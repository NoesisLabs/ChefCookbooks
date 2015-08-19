powershell_script 'Install Chocolatey' do
  code "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
  not_if "choco -h"
end