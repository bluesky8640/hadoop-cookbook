# Use
#class Chef::Recipe
#        include SUDO_PASSWORD
#end

#sudo_password = get_sudo_password()

module SUDO_PASSWORD
	def get_sudo_password

		# Data bag id attribute
		data_bag_infra_id = node['data_bag_infra_id']

		# node's hostname
		hostname = node['hostname']

		# access data bag values
		infra = data_bag_item('hadoop', data_bag_infra_id)

		# return server's password
		password = infra['password'][hostname]

		# debug
		if node['debug']
			Chef::Log.info "hostname: #{hostname}"
			Chef::Log.info "password: #{sudo_password}"
		end
		password
	end
end
