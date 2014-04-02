#
# Cookbook Name:: hadoop
# Recipe:: ssh_public_keys 
#
#
require 'chef/shell_out'


##
## Generating User's password
##
# password = Mixlib::ShellOut.new("mkpasswd -m sha-512 #{node['hadoop_user_password']}")
password = Mixlib::ShellOut.new("openssl passwd -1 #{node['hadoop_user_password']}")
password.run_command


##
## Create hadoop user
##
log "Creating Hadoop user: #{node['hadoop_user']}"
user node['hadoop_user'] do
        supports :manage_home => true
        comment "Hadoop user"
        home node['hadoop_user_home']
        shell "/bin/bash"
        password password.stdout.chomp
	action :create
end


##
## Create .ssh directory under Hadoop user's home
##
directory "#{node['hadoop_user_home']}/.ssh" do
      mode "0700"
      owner node['hadoop_user']
      group node['hadoop_user']
      action :create
      recursive true
end


#ssh_dir = Mixlib::ShellOut.new('mkdir', ".ssh", :user => node['hadoop_user'], :cwd => node['hadoop_user_home'])
#ssh_dir.run_command

#log "Generating ssh keys"
#bash "Generating ssh keys[bash]" do
#	user	node['hadoop_user']
#	group	node['hadoop_user']
#	cwd	"#{node['hadoop_user_home']}/.ssh"
#	code	<<-EOF
#	ssh-keygen -f id_rsa -N "" -t rsa
#	EOF
#end


# Generate SSH keys
gen_ssh_keys = Mixlib::ShellOut.new('ssh-keygen -f id_rsa -N "" -t rsa', :cwd => "/tmp")
gen_ssh_keys.run_command

# Share SSH public key
log "Sharing node's public key"
get_pub_key = Mixlib::ShellOut.new('cat', 'id_rsa.pub', :cwd => "/tmp")
get_pub_key.run_command

if !(get_pub_key.error!)
	log "Sharing string OK"
else
	log "Sharing string FAILED" do
		level :warn
	end
end
# Set node public key
node.set["public_key"] = get_pub_key.stdout
log "public_key attribute updated"

# Move SSH keys to hadoop workspace
bash "Moving keys to hadoop user's home" do
       user    "root"
       group   "root"
       cwd     "/tmp"
       code    <<-EOF
		mv id_rsa* #{node['hadoop_user_home']}/.ssh
		chown #{node['hadoop_user']}:#{node['hadoop_user']} #{node['hadoop_user_home']}/.ssh/*
       EOF
end
