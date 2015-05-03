#
# Cookbook Name:: boser
# Recipe:: misc
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#variabili d'ambiente
file '/home/vagrant/.bash_profile' do
  content "export CATALINA_HOME=/opt/apache-tomcat-8.0.21
  export BOSER_WKS=/home/ubuntu/git/prototipo1/boser-web
  alias l='ls -a'
  alias ll='ls -l'
  alias la='ls -la'
  alias tailf='tail -f'
  "
end
