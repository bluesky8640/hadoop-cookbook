#
# Cookbook Name:: hadoop
# Recipe:: setup_master
#
#
require 'chef/shell_out'

#Search all nodes within Hadoop Cluster
#nodes = search(:node, "role:#{node['hadoop_cluster_role']}").sort_by { |h| h[:hostname] }
nodes = search(:node, "name:*#{node['cluster_name']}*").sort_by { |h| h[:hostname] }
nodes.delete_if { |h| h[:hostname] == node[:hostname] }
log "Delete Master from nodes"

# Update conf/masters
log "Updating conf/masters with #{node['hadoop_master']}"
template "#{node['hadoop_home']}/#{node['hadoop_release']}/conf/masters" do
  source "masters.erb"
  owner node['hadoop_user']
  group node['hadoop_user']
  mode 0644
  variables(
    :hadoop_master => node['hadoop_master']
  )
end


# Update conf/slaves
log "Updating conf/slaves with #{nodes}"
template "#{node['hadoop_home']}/#{node['hadoop_release']}/conf/slaves" do
  source "slaves.erb"
  owner node['hadoop_user'] 
  group node['hadoop_user']
  mode 0644
  variables(
    :hosts => nodes
  )
end

# Verify ssh connectivity
log "Verifying SSH conectivity"
nodes.each do |n|
	ssh_test = Mixlib::ShellOut.new("ssh -o StrictHostKeyChecking=no #{n["hostname"]} 'free' ", :user => node['hadoop_user'])
	ssh_test.run_command
	if !(ssh_test.error!)
		log "Node #{n['hostname']} OK"
	else
		log "Node #{n['hostname']} fail" do
			level :warn
		end
	end
end

# Format Namenode
log "Formating Namenode"
format_namenode = Mixlib::ShellOut.new("echo 'Y' | bin/hadoop namenode -format", :user => node['hadoop_user'], :cwd => "#{node['hadoop_home']}/#{node['hadoop_release']}")
format_namenode.run_command

if !(format_namenode.error!)
	log "Namenode storage directory has been successfully formatted"
else
	log "Namenode storage directory could not be formatted"	do
		level :warn
	end
end

# Set SSH Config
log "Setting SSH Config"
set_ssh_config =  Mixlib::ShellOut.new("sed -i \"s:#.*StrictHostKeyChecking.*$:StrictHostKeyChecking no:g\" ssh_config", :cwd => "/etc/ssh", :user => "root", :group => "root")
set_ssh_config.run_command

if !(set_ssh_config.error!)
        log "SSH Config was successfully set"
else
        log "SSH Config was not set"
end

# Restart SSH Server
service "ssh" do
	action :restart
end
