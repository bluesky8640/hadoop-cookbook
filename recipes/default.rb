#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

'''
log "-----Start to install hadoop-----"

# Setup hosts
order = 1
if (order == 1)
	log "Order = 1: setup hosts"
	include_recipe "hadoop::setup_hosts"
	order = 2
else
	log "Order != 1"
end

# Setup SSH keys
if (order == 2)
	log "Order = 2: setup ssh keys"
	include_recipe "hadoop::authorized_nodes"
	order = 3
else
	log "Order != 2"
end

# Install java
if (order == 3)
	log "Order = 3: install java"
	include_recipe "java"
	order = 4
else
	log "Order != 3"
end

# Install hadoop
if (order == 4)
	log "Order = 4: install hadoop"
	include_recipe "hadoop::setup_hadoop"
else
	log "Order != 4"
end
'''

include_recipe "java"

'''
include_recipe "hadoop::setup_hadoop"

# Configuration for master node
hostname_elements = (node[:hostname]).split("-")
number = hostname_elements[3]

if (number == "1")
	log "This is a hadoop master node" 
	include_recipe "hadoop::setup_master"
	include_recipe "hadoop::start_hadoop"
else
	log "This is a hadoop slave node"
end
'''
