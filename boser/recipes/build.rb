#
# Cookbook Name:: boser
# Recipe:: build
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#build e creazione pacchetto

package 'maven' do
  retries 1
  retry_delay 2
  action :install
end

package 'git' do
  action :install
end

directory '/home/ubuntu/git' do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

git "/home/ubuntu/git" do
  repository "https://github.com/vernyquartara/prove.git"
  revision "master"
  action :sync
end

execute 'build' do
  cwd '/home/ubuntu/git/prototipo1/boser-web'
  command "mvn clean package -DskipTests=true -DDB_URL=#{node['boser']['db']['dburl']} -DDB_NAME=boser"
end

execute 'deploy' do
  cwd '/home/ubuntu'
  command "wget -o deploy.log --output-document=deploy.html "\
          "--http-user='jenkins' --http-password='j3Nk!n6' "\
          "'http://localhost:8080/manager/text/deploy?path=/&"\
          "war=file:/home/ubuntu/git/prototipo1/boser-web/target/boser-web-1.0.0.war '"
end
