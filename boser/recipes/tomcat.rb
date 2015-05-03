#
# Cookbook Name:: boser
# Recipe:: tomcat
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#creazione utente tomcat
user 'tomcat' do
  supports :manage_home => true
  comment 'Apache Tomcat User'
  home '/home/tomcat'
  action :create
end

#creazione repository di Boser
directory '/home/tomcat/boser-repo' do
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end

#creazione log dir
directory '/var/log/boser' do
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end

#file di configurazione di quartz
file '/home/tomcat/quartz.properties' do
  owner 'tomcat'
  group 'tomcat'
  mode '0644'
  content "
  #============================================================================
  # Configure Main Scheduler Properties
  #============================================================================

  org.quartz.scheduler.instanceName: BoserScheduler
  org.quartz.scheduler.instanceId: AUTO

  org.quartz.scheduler.skipUpdateCheck: true

  #============================================================================
  # Configure ThreadPool
  #============================================================================

  org.quartz.threadPool.class: org.quartz.simpl.SimpleThreadPool
  org.quartz.threadPool.threadCount: 3
  org.quartz.threadPool.threadPriority: 5

  #============================================================================
  # Configure JobStore
  #============================================================================

  org.quartz.jobStore.misfireThreshold: 60000

  #org.quartz.jobStore.class: org.quartz.simpl.RAMJobStore

  org.quartz.jobStore.class: org.quartz.impl.jdbcjobstore.JobStoreTX
  org.quartz.jobStore.driverDelegateClass: org.quartz.impl.jdbcjobstore.StdJDBCDelegate
  # The org.quartz.jobStore.useProperties config parameter can be set to true (it defaults to false)
  # in order to instruct JDBCJobStore that all values in JobDataMaps will be Strings,
  # and therefore can be stored as name-value pairs, rather than storing more complex objects
  # in their serialized form in the BLOB column. This is much safer in the long term, as you avoid
  # the class versioning issues that come with serializing non-String classes into a BLOB.
  org.quartz.jobStore.useProperties: false
  org.quartz.jobStore.dataSource: BoserQuartzDS
  org.quartz.jobStore.tablePrefix: QRTZ_
  org.quartz.jobStore.isClustered: false

  #============================================================================
  # Configure Datasources
  #============================================================================

  org.quartz.dataSource.BoserQuartzDS.jndiURL=java:comp/env/jdbc/QuartzDS
  "
end

#download tomcat
remote_file "#{Chef::Config[:file_cache_path]}/apache-tomcat-8.0.21.tar.gz" do
  source "http://it.apache.contactlab.it/tomcat/tomcat-8/v8.0.21/bin/apache-tomcat-8.0.21.tar.gz"
  checksum   '7972dfc3a1e9b9a78738379f7e755a11 *apache-tomcat-8.0.21.tar.gz'
end

bash "unpack tomcat" do
  code <<-EOS
    sudo tar xzf #{Chef::Config[:file_cache_path]}/apache-tomcat-8.0.21.tar.gz -C /opt
  EOS
end

#permessi
execute 'chown tomcat directory' do
  command 'chown -R tomcat:tomcat /opt/apache-tomcat-8.0.21'
end

#impostazione JAVA_OPTS
file '/opt/apache-tomcat-8.0.21/bin/setenv.sh' do
  content 'export JAVA_OPTS="-Dorg.quartz.properties=/home/tomcat/quartz.properties -Xmx512M"'
end

#impostazione utenti e ruoli
cookbook_file "tomcat-users.xml" do
  path "/opt/apache-tomcat-8.0.21/conf/tomcat-users.xml"
end

bash "start tomcat" do
  code <<-EOS
    sudo -u tomcat /opt/apache-tomcat-8.0.21/bin/startup.sh
  EOS
end

#undeploy applicazione ROOT
execute 'undeploy ROOT' do
  cwd '/home/ubuntu'
  command "wget wget -o undeploy.log --output-document=undeploy.html "\
          "--http-user='jenkins' --http-password='j3Nk!n6' "\
          "'http://localhost:8080/manager/text/undeploy?path=/'"
end
