batch 'Configure Timezone' do
  code <<-EOH
  tzutil.exe /s "#{node[:timezone]}"
  EOH
  action :run
end