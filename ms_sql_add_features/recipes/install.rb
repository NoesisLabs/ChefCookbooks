require 'win32/service'

powershell_script "add SQL features" do
  code <<-EOH
  $mount = Mount-DiskImage -ImagePath "#{node[:mssqladdfeature][:installation_iso_path]}" -PassThru
  & "$((Get-Volume -DiskImage $mount).DriveLetter):\\Setup.exe" /qa /ACTION=Install /FEATURES="#{node[:mssqladdfeature][:feature_list]}" /IACCEPTSQLSERVERLICENSETERMS
  Dismount-DiskImage $mount.ImagePath
  EOH
  action :run
end