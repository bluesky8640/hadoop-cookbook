#
# Cookbook Name:: hadoop
# Recipe:: setup_hosts
#
#
require 'chef/shell_out'

# Backup original /etc/hosts
backup_hosts = Mixlib::ShellOut.new("cp /etc/hosts /etc/hosts.original")
backup_hosts.run_command

log "File /etc/hosts backed up"

#Search all nodes within Hadoop Cluster
#nodes = search(:node, "role:#{node['hadoop_cluster_role']}")
nodes = search(:node, "name:*#{node['cluster_name']}*")

# Update /etc/hosts
template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :hosts => nodes.sort_by { |h| h[:hostname] }
  )
end


