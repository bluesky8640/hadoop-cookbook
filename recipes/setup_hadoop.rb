#
# Cookbook Name:: hadoop
# Recipe:: setup_hosts
#
#
require 'chef/shell_out'

# Find out JAVA_HOME
log "Searching for JAVA_HOME"
find_java_home = Mixlib::ShellOut.new("find / -name jps -type f  | grep bin")
find_java_home.run_command

if !(find_java_home.error!)
        java_home = find_java_home.stdout.split("/").delete_if {|x| x == "bin" || x == "jps\n"}.join("/")
        log "JAVA_HOME found in #{java_home}"
else
        log "JAVA_HOME not found" do
		level :warn
	end
end

# Create Hadoop home directory
log "Creating Hadoop home directory"
e = directory node['hadoop_home'] do
  owner node['hadoop_user']
  group node['hadoop_user']
  mode 00755
  action :create
end
e.run_action(:create)

# Download Hadoop package
log "Downloading Hadoop package"
download_hadoop = Mixlib::ShellOut.new("wget #{node['hadoop_package_uri']}", :user => node['hadoop_user'], :cwd => '/tmp')
download_hadoop.run_command

# Extract Hadoop package
log "Extracting Hadoop"
download_hadoop = Mixlib::ShellOut.new("tar -xzf #{node['hadoop_release']}.tar.gz -C #{node['hadoop_home']}", :user => node['hadoop_user'], :group => node['hadoop_user'], :cwd => '/tmp')
download_hadoop.run_command


# Setup configuration files
log "Seting up Hadoop configuration files"
log "conf/hdfs-site.xml"
template "#{node['hadoop_home']}/#{node['hadoop_release']}/conf/hdfs-site.xml" do
    owner node['hadoop_user']
    group node['hadoop_user']
    source "hdfs-site.xml.erb"
    variables ({
	:hdfs_replication => node['hdfs_replication'],
	:hadoop_namenode_dir => node['hadoop_namenode_dir'],
	:hadoop_datanode_dir => node['hadoop_datanode_dir']
    })
end

log "conf/core-site.xml"
template "#{node['hadoop_home']}/#{node['hadoop_release']}/conf/core-site.xml" do
    owner node['hadoop_user']
    group node['hadoop_user']
    source "core-site.xml.erb"
    variables ({ :hadoop_namenode => node['hadoop_master'] })
end

log "conf/mapred-site.xml"
template "#{node['hadoop_home']}/#{node['hadoop_release']}/conf/mapred-site.xml" do
    owner node['hadoop_user']
    group node['hadoop_user']
    source "mapred-site.xml.erb"
    variables ({ 
	:hadoop_jobtracker => node['hadoop_master'],
	:hadoop_tasktracker_local_dir => node['hadoop_tasktracker_local_dir']
    })
end

# Creating NN, DN and TT directories
log "Creating NN, DN and TT directories"
create_dir = Mixlib::ShellOut.new("mkdir -p #{node['hadoop_namenode_dir']} #{node['hadoop_datanode_dir']} #{node['hadoop_tasktracker_local_dir']}" , :user => node['hadoop_user'], :group => node['hadoop_user'], :cwd => node['hadoop_home'])
create_dir.run_command

# Set JAVA_HOME
log "Setting JAVA_HOME"
set_java_home =  Mixlib::ShellOut.new("sed -i \"s:#.*JAVA_HOME=.*$:export JAVA_HOME=#{java_home}:g\" conf/hadoop-env.sh", :cwd => "#{node['hadoop_home']}/#{node['hadoop_release']}", :user => node['hadoop_user'], :group => node['hadoop_user'])
set_java_home.run_command

if !(set_java_home.error!)
        log "JAVA_HOME was successfully set"
else
        log "JAVA_HOME was not set"
end

