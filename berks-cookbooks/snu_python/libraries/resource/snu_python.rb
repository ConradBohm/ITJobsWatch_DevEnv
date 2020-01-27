# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python
#
# Copyright:: 2018, Socrata, Inc.
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

require 'chef/dsl/declare_resource'
require 'chef/resource'
require 'json'

class Chef
  class Resource
    # A Chef resource for managing our Python installs.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPython < Chef::Resource
      include Chef::DSL::DeclareResource

      property :python3_packages, Array, default: %w[requests]
      property :python2_packages, Array, default: %w[requests]

      default_action :install

      #
      # If a python_package or pip_requirements resources is declared and
      # given one of the python_runtime resources that this resource sets up,
      # that runtime needs to be available at compile time or poise-python will
      # raise an exception. It doesn't need to be installed, though, so we can
      # add one with action :nothing to the resource collection and do the real
      # work in the action blocks at converge time.
      #
      def after_created
        %w[3 2].each do |p|
          pyr = declare_resource(:python_runtime, p)
          pyr.options(package_upgrade: true) if action.include?(:upgrade)
          pyr.action(:nothing)
        end
      end

      #
      # The :install and :upgrade actions should pass themselves on to the
      # python_package resources for the base package sets. The action on the
      # runtime happens above in after_created.
      #
      %i[install upgrade].each do |act|
        action act do
          %w[3 2].each do |py|
            python_runtime py do
              options package_upgrade: true if act == :upgrade
            end

            next if new_resource.send("python#{py}_packages").empty?

            python_package "Python #{py} pip packages" do
              package_name new_resource.send("python#{py}_packages")
              python py
              action act
            end
          end

          file '/usr/local/bin/pip' do
            src = '/usr/local/bin/pip2'

            owner(lazy { ::File.stat(src).uid })
            group(lazy { ::File.stat(src).gid })
            mode(lazy { ::File.stat(src).mode.to_s(8)[1..-1] })
            content(lazy { ::File.read(src) })
          end
        end
      end

      #
      # The :remove action should purge all installed Python packages and then
      # Python runtimes.
      #
      action :remove do
        %w[3 2].each do |py|
          if ::File.exist?("/usr/bin/python#{py}")
            python_package "All Python #{py} pip packages" do
              package_name(
                lazy do
                  stdout = shell_out!(
                    "/usr/bin/python#{py} -m pip.__main__ list --format=json"
                  ).stdout
                  pkgs = JSON.parse(stdout).map { |pkg| pkg['name'] }
                  pkgs.reject do |p|
                    owned_by_system_package?(p, "/usr/bin/python#{py}")
                  end
                end
              )
              python py
              action :remove
            end
          end

          python_runtime(py) { action :uninstall }
        end
      end

      action_class do
        #
        # Examine a pip package's install path to determine whether it's owned
        # by a system package or was installed with pip.
        #
        # @param pkg [String] a Python package name
        # @param python [String] path to a Python binary
        # @return [TrueClass,FalseClass] whether a system package owns it
        #
        def owned_by_system_package?(pkg, python = 'python')
          stdout = shell_out!("#{python} -m pip.__main__ show #{pkg}").stdout
          line = stdout.lines.find { |l| l.start_with?('Location:') }
          path = line.gsub(/^Location: /, '')
          path.start_with?('/usr/lib/')
        end
      end
    end
  end
end
