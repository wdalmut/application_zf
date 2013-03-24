#
# Cookbook Name:: application_zend
# Recipe:: default
#
# Copyright 2009-2010, Walter Dal Mut.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt"
include_recipe "apache2"
include_recipe "php"

#TODO: add apc

path_on_disk = String.new(node['zend']['version'])
path_on_disk["/"] = "_"

if node['zend']['version'] == 'latest'
  require 'open-uri'
  remote_file  "#{Chef::Config[:file_cache_path]}/latest.tar.gz" do
    source "https://github.com/zendframework/ZendSkeletonApplication/archive/master.tar.gz"
    mode "0644"
  end
else
  remote_file "#{Chef::Config[:file_cache_path]}/#{path_on_disk}.tar.gz" do
    source "https://github.com/zendframework/ZendSkeletonApplication/archive/#{node['zend']['version']}.tar.gz"
    mode "0644"
  end
end

directory "#{node['zend']['dir']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

execute "unzip-zend" do
  cwd node['zend']['dir']
  command "tar -xzf #{Chef::Config[:file_cache_path]}/#{path_on_disk}.tar.gz --strip 1"
end

apache_site "000-default" do
  enable false
end

web_app "zend" do
  template "zend.conf.erb"
  docroot "#{node['zend']['dir']}"
  server_name node['zend']['server_name']
  server_aliases node['zend']['server_aliases']
end