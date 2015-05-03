#
# Cookbook Name:: boser
# Recipe:: nginx
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#installazione di nginx
package 'nginx' do
  action :install
end

#creazione virtual host per mapping porta 8080 su porta 80
file '/etc/nginx/conf.d/boser.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "server {
      listen 80;
      server_name boser.quartara.it;
      location / {
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   Host      $http_host;
          proxy_pass         http://127.0.0.1:8080;
      }
  }
  "
end

#riavvio
execute 'restart nginx' do
  command 'sudo service nginx restart'
end
