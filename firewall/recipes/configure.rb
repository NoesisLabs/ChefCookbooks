node[:firewall][:allow].each do |rule|
  powershell_script "Configure Firewall Setting #{rule['name']}" do
    code <<-EOH
    New-NetFirewallRule -DisplayName "#{rule['name']}" -Direction #{rule['direction']} -LocalPort #{rule['port']} -Protocol #{rule['protocol']} -Profile Any -Action Allow
    EOH
    action :run
    not_if "netsh advfirewall firewall show rule name=\"#{rule['name']}\" > nul"
  end
end

node[:firewall][:block].each do |rule|
  powershell_script "Configure Firewall Setting #{rule['name']}" do
    code <<-EOH
    New-NetFirewallRule -DisplayName "#{rule['name']}" -Direction #{rule['direction']} -LocalPort #{rule['port']} -Protocol #{rule['protocol']} -Profile Any -Action Block
    EOH
    action :run
    not_if "netsh advfirewall firewall show rule name=\"#{rule['name']}\" > nul"
  end
end