Description
===========

Installs and configures a basic Hadoop cluster on a set of servers. By default, HDFS and MapReduce services must be manually started.

Requirements
============

Platform
--------

Tested on Ubuntu 12.04

Attributes
==========

Hadoop user's attributes
-----------------------

* default['hadoop_user'] => Hadoop user
* default['hadoop_user_password'] => Hadoop user's password
* default['hadoop_user_home'] => Hadoop user's home directory
* default['public_key'] => Hadoop user's public key


Hadoop cluster attributes
-------------------------

* default['hadoop_cluster_role'] => Hadoop default cluster role
* default['hadoop_master'] => Master hadoop node
* default['hdfs_replication'] => Hadoop replication factor
* default['hadoop_package_uri'] => Hadoop package URI
* default['hadoop_release'] => Hadoop package
* default['hadoop_home'] => Hadoop home directory
* default['hadoop_namenode_dir'] => Hadoop Namenode directory
* default['hadoop_datanode_dir'] => Hadoop Datanode directory
* default['hadoop_tasktracker_local_dir'] => Hadoop Datanode directory

Usage
=====

Export your chef repository:

	export CHEF_REPO=/path/to/your/chef-repo

Install Librarian:

	gem install librarian

Go to your CHEF_REPO parent directory and initilize Cheffile file:

	librarian-chef init
	echo -e "cookbook 'java',\n\t:git => 'https://github.com/opscode-cookbooks/java'\n" >> Cheffile
	echo -e "cookbook 'ufw',\n\t:git => 'https://github.com/opscode-cookbooks/ufw'\n" >> Cheffile
	echo -e "cookbook 'hadoop',\n\t:git => 'https://github.com/baremetalcloud/hadoop-cookbook'\n" >> Cheffile
	librarian-chef update

Create the Hadoop default role. This role will be used to tag each server within Hadoop cluster. 
Remember to update `hadoop_master` attribute so it represents the master server.

	cat << EOF > $CHEF_REPO/roles/hadoop.rb
	name "hadoop"
	description "Hadoop default role"
	
	override_attributes "hadoop" => {
		"hadoop_master" => "<node_client>"
	}
	
	EOF

Create a role to set the ssh public key for hadoop user:

	cat << EOF > $CHEF_REPO/roles/ssh-pub-key.rb
	name "ssh-pub-key"
	description "Update ssh_keys databag with node pub key"
	run_list [
		"recipe[hadoop::ssh_public_keys]"
	]
	EOF

Create a role to store the hadoop user public key in authorized_keys file:

	cat << EOF > $CHEF_REPO/roles/ssh-authorized-key.rb
	name "ssh-authorized-key"
	description "Update authorized keys on all nodes"
	run_list [
		"recipe[hadoop::authorized_nodes]"
	]
	EOF

Create a role to setup hosts file:

	cat << EOF > $CHEF_REPO/roles/setup-hosts.rb
	name "setup-hosts"
	description "Setup /etc/hosts file on all nodes"
	run_list [
		"recipe[hadoop::setup_hosts]"
	]
	EOF

Create a role to setup Hadoop Framework:

	cat << EOF > $CHEF_REPO/roles/setup-hadoop.rb
	name "setup-hadoop"
	description "Setup Hadoop package on all nodes"
	run_list [
		"recipe[hadoop::setup_hadoop]","recipe[ufw::default]"
	]
	override_attributes "firewall" => {
	                "rules" => [
	                	{ "data_node_communication"	=> {"port" => "50010"}},
	                	{ "task_tracker_admin"  => {"port" => "50060"}},
	                	{ "data_node_admin" => {"port" => "50075"}}
	                ]
	}
	EOF

Create a role to setup the master server. JobTracker and Namenode will run on this server.

	cat << EOF > $CHEF_REPO/roles/setup-master.rb
	name "setup-master"
	description "Setup Hadoop master node"
	run_list [
		"recipe[hadoop::setup_master]","recipe[ufw::default]"
	]
	override_attributes "firewall" => {
	                "rules" => [
	                	{ "job_tracker_ui"  => {"port" => "50030"}},
	                	{ "name_node_ui"  => {"port" => "50070"}},
	                	{ "name_node_communication"	=> {"port" => "54310"}},
	                	{ "job_tracker_communication" => {"port" => "54311"}}
	                ]
	}
	
	EOF

Java must be installed on all servers. This cookbook requires java which can be installed by the role below:

	cat << EOF > $CHEF_REPO/roles/java.rb
	name "java"
	description "Setup Java packages"
	run_list [
		"recipe[java::default]"
	]
	default_attributes "java" => {
			"jdk_version" => "7"
	}
	EOF


Upload all roles

	knife role from file java.rb
	knife role from file hadoop.rb
	knife role from file ssh-pub-key.rb
	knife role from file ssh-authorized-key.rb
	knife role from file setup-hosts.rb
	knife role from file setup-hadoop.rb
	knife role from file setup-master.rb

Upload all cookbooks

	knife cookbook upload chef_handler
	knife cookbook upload windows
	knife cookbook upload java
	knife cookbook upload firewall
	knife cookbook upload ufw
	knife cookbook upload hadoop

Example
======

1) Boostrap all servers with the following roles:

	knife bootstrap <IP> -N <node_name> -x root -P <password> -r 'role[hadoop],role[java],role[ssh-pub-key]'


2) Remove `java` and `ssh-pub-key` roles from all servers:

	knife node run_list remove <node_name> 'role[java],role[ssh-pub-key]'


3) Add roles `ssh-authorized-key`, `setup-hosts` and `setup-hadoop` on all servers:

	knife node run_list add <node_name> 'role[ssh-authorized-key],role[setup-hosts],role[setup-hadoop]'


4) Run `chef-client` on all servers.


5) Remove `ssh-authorized-key`, `setup-hosts` and `setup-hadoop` roles from all servers:

	knife node run_list remove <node_name> 'role[ssh-authorized-key],role[setup-hosts],role[setup-hadoop]'

6) Add `setup-master` role only on the server that will run JobTracker and NameNode:

	knife node run_list add <node_name> 'role[setup-master]'


7) Run `chef-client` on the master server.


8) Go to `node[hadoop_home]/node['hadoop_release']` directory and startup NameNode and JobTracker services:

	bin/start-dfs.sh
	bin/start-mapred.sh

License and Author
==================

Author:: Diego Desani (<diego@baremetalcloud.com>)

Copyright:: 2013, baremetalcloud Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
