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

log "Add Galaxy server's public key"
bash "add galaxy public key" do
	user node['hadoop_user']
	group node['hadoop_user']
	cwd "/home/#{node['hadoop_user']}/.ssh"
	code <<-EOF
		sed -i '$a ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx+CvTGWPG8tkI16iDfg1p2piLaZGJ1jqvH69oqDdsDNeCs8h+j55CqB/MvBLwj+cShTCVn7iPhzGjhoBrxNDp50Tv/to4uVwkB032Dp805cOXoAifqufEfWr562wC/UJ9qhO7uD4ByaI9hC4kmya6gSB31BloeDN9k7/uH7x/FFkvkA40f2wSgUqoKTrjvi2TBRy4FjMhj8z9+/HyT3hXByx2qYCLPYUVEEnLPkPCK5GjA5M7VBCn71RrwROYQIvbf7styhZJ0lINst5tnWk5sY/GYXlef0lLi7LwswrUV+c/zJAnwclffmwp94BKPG62qhd6Bkcd7tAHerOixu/1 jinchao@saasslave04' authorized_keys
	EOF
end

log "Cancel strict host key checking"
bash "cancel strict key check" do
	user "root"
	group "root"
	cwd "/etc/ssh"
	code <<-EOF
		sed -i 's/#.*StrictHostKeyChecking.*$/StrictHostKeyChecking no/g' ssh_config
	EOF
end

log "Public keys were successfully added"
