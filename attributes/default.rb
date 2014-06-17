#
# Hadoop Cookbook Attributes
#

##
## Hadoop user's attributes
##

# Hadoop user
default['hadoop_user'] = 'hadoop'

# Hadoop user's password
default['hadoop_user_password'] = 'hadoop'

# Hadoop user's home directory
default['hadoop_user_home'] = "/home/#{node['hadoop_user']}"

# Hadoop user's public key
default['public_key'] = ''


##
## Hadoop package attributes
##

# Hadoop default cluster role
default['hadoop_cluster_role'] = 'hadoop'

# Master hadoop node.
default['hadoop_master'] = ''

# Hadoop replication factor
default['hdfs_replication'] = 2

# Hadoop package URI
# default['hadoop_package_uri'] = 'http://www.us.apache.org/dist/hadoop/common/hadoop-1.0.4/hadoop-1.0.4.tar.gz'
default['hadoop_package_uri'] = 'ftp://saasslave04/hadoop-1.2.1.tar.gz'

# Hadoop package
# default['hadoop_release'] = 'hadoop-1.0.4'
default['hadoop_release'] = 'hadoop-1.2.1'

# Hadoop home directory
default['hadoop_home'] = '/hadoop'

# Hadoop Namenode directory
default['hadoop_namenode_dir'] = '/hadoop/dfs/nn'

# Hadoop Datanode directory
default['hadoop_datanode_dir'] = '/hadoop/dfs/dn'

# Hadoop Datanode directory
default['hadoop_tasktracker_local_dir'] = '/hadoop/mapred/jt'


##
## Cluster attributes
##

# Cluster Name
default['cluster_name'] = ''
