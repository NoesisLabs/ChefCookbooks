node[:firewall][:allow].each do |name, direction, protocol, port|
  powershell_script "Configure Firewall Setting #{name}" do
    code <<-EOH
    New-NetFirewallRule -DisplayName "#{name}" -Direction #{direction} -LocalPort #{port} -Protocol #{protocol} -Action Allow
	$smtp.#{key} = #{value}
	$smtp.put()
    EOH
    action :run
    not_if "netsh advfirewall firewall show rule name=\"#{name}\" > nul"
  end
end

node[:firewall][:block].each do |name, direction, protocol, port|
  powershell_script "Configure Firewall Setting #{name}" do
    code <<-EOH
    New-NetFirewallRule -DisplayName "#{name}" -Direction #{direction} -LocalPort #{port} -Protocol #{protocol} -Action Block
	$smtp.#{key} = #{value}
	$smtp.put()
    EOH
    action :run
    not_if "netsh advfirewall firewall show rule name=\"#{name}\" > nul"
  end
end