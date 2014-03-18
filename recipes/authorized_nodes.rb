#
# Cookbook Name:: hadoop
# Recipe:: authorized_nodes 
#
#

require 'chef/shell_out'

# Cluster name for this node
hostname_elements = (node[:hostname]).split("-")
node.set['cluster_name'] = hostname_elements[1]
log "Cluster Name: #{node['cluster_name']}"

# String for cluster public keys
authorized_keys = ''

# Search all nodes within the cluster
# nodes = search(:node, "role:#{node['hadoop_cluster_role']}")
nodes = search(:node, "name:*#{node['cluster_name']}*").sort_by { |h| h[:hostname] }

# Collect nodes' public keys
nodes.each do |node|
	authorized_keys << node['public_key']	
end

# Create 'authorized_keys' file withh authorized_keys variable
e = file "/home/#{node['hadoop_user']}/.ssh/authorized_keys" do
  content authorized_keys
  action :create
end

log "Public keys were successfully added"
