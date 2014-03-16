name		 "hadoop"
maintainer       "BUAA, Org."
maintainer_email "bluesky8640@126.com"
license          "All rights reserved"
description      "Installs/Configures hadoop"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
depends		 "java"

recipe "hadoop::default", "Include java"
recipe "hadoop::ssh_public_keys", "Generate ssh public keys"
recipe "hadoop::authorized_nodes", "Configure ssh verification" 
recipe "hadoop::setup_hosts", "Setup /etc/hosts"
recipe "hadoop::setup_hadoop", "Install Hadoop"
recipe "hadoop::setup_master", "Configure Master"

%w{ ubuntu }.each do |os|
  supports os
end

# %w{ java ufw }.each do |dep|
# depends dep
# end
