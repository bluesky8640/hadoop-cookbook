#
# Cookbook Name:: hadoop
# Recipe:: authorized_nodes 
#
#

require 'chef/shell_out'

# String for cluster public keys
authorized_keys = ''

# Search all nodes within the cluster
nodes = search(:node, "role:#{node['hadoop_cluster_role']}")

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
