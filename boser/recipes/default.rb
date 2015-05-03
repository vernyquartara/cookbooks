#
# Cookbook Name:: boser
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#include_recipe 'apt'
include_recipe 'boser::misc'
include_recipe 'boser::nginx'
include_recipe 'boser::tomcat'
include_recipe 'boser::build'
