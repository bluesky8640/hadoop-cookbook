#
# Cookbook Name:: hadoop
# Recipe:: start_hadoop
#
#
require 'chef/shell_out'

# Start Hadoop
log "Start Hadoop"
start_hadoop = Mixlib::ShellOut.new("bin/start-all.sh", :user => node['hadoop_user'], :cwd => "#{node['hadoop_home']}/#{node['hadoop_release']}")
start_hadoop.run_command

if !(start_hadoop.error!)
        log "Start hadoop successfully!"
else
        log "Start hadoop failed!" do
                level :warn
        end
end
