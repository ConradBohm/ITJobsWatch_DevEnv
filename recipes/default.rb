#
# Cookbook:: dev_env
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

include_recipe 'snu_python'
include_recipe 'apt'

apt_update 'update_sources' do
  action :update
end

bash 'installing app dependancies' do
  code <<-PUPPIES
    pip3 install atomicwrites==1.3.0
    pip3 install attrs==19.1.0
    pip3 install beautifulsoup4=4.8.0
    pip3 install bs4
    pip3 install certifi==2019.6.16
    pip3 install chardet==3.0.4
    pip3 install config_manager
    pip3 install idna==2.8
    pip3 install importlib-metadata==0.19
    pip3 install more-itertools==7.2.0
    pip3 install packaging==19.1
    pip3 install pluggy==0.13.1
    pip3 install py==1.8.0
    pip3 install pyparsing==2.4.2
    pip3 install pytest==5.1.0
    pip3 install requests==2.22.0
    pip3 install six==1.12.0
    pip3 install soupsieve==1.9.2
    pip3 install urllib3==1.25.3
    pip3 install wcwidth==0.1.7
    pip3 install zipp==0.5.2
  PUPPIES
end

bash 'configuring download folder for app' do
  code <<-PUPPIES
    cd /home/vagrant
    mkdir Downloads
    sudo chmod 777 /home
    sudo chmod 777 /home/vagrant
    sudo chmod 777 /home/vagrant/Downloads
  PUPPIES
end

remote_directory '/home/ubuntu/app' do
  source 'app'
  owner 'root'
  group 'root'
  recursive true
  action :create
end
