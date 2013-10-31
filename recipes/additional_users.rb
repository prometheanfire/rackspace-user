#
# Cookbook Name:: rackspace-user
# Recipe:: additional_users
#
# Copyright (C) 2013 Rackspace
# 
# All rights reserved - Do Not Redistribute
#

node['rackspace']['users'].each do |user, data|

  unless node['rackspace']['users']["#{user}"]['enabled'] == false

    user "#{user}" do
      unless node['rackspace']['users']["#{user}"]['uid'].nil?
        uid node['rackspace']['users']["#{user}"]['uid']
      end

      unless node['rackspace']['users']["#{user}"]['password'].nil?
        password node['rackspace']['users']["#{user}"]['password']
      end

      shell node['rackspace']['users']["#{user}"]['shell']
      home node['rackspace']['users']["#{user}"]['home']
      comment node['rackspace']['users']["#{user}"]['note']
      supports :manage_home=>false

    	action :create
    end

    if node['rackspace']['users']["#{user}"]['manage_home'] == true
      directory node['rackspace']['users']["#{user}"]['home'] do
       	owner "#{user}"
       	group "#{user}"
       	mode "0700"
        recursive true
       	action :create
      end
      
      unless node['rackspace']['users']["#{user}"]['authorized_keys'].nil?
        directory node['rackspace']['users']["#{user}"]['home'] + "/.ssh" do
         	owner "#{user}"
         	group "#{user}"
        	mode "0700"
        	action :create
        end

        template node['rackspace']['users']["#{user}"]['home'] + "/.ssh/authorized_keys" do
          source "authorized_keys.erb"
          mode "0600"
          owner "#{user}"
          group "#{user}"
          variables ({
            :keys => node['rackspace']['users']["#{user}"]['authorized_keys']
            })
        end          
      end        
    end
    
    if node['rackspace']['users']["#{user}"]['sudo'] == true

      sudo "#{user}" do
        user "#{user}"
        nopasswd true
      end

    end

  end

end

include_recipe "sudo"