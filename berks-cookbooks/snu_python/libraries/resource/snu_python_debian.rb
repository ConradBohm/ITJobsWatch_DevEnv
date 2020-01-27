# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: resource/snu_python_debian
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

require_relative 'snu_python'
require_relative '../helpers/snu_python_debian'

class Chef
  class Resource
    # A Chef resource for managing our Python installs on Debian/Ubuntu.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class SnuPythonDebian < Chef::Resource::SnuPython
      provides :snu_python, platform_family: 'debian'

      #
      # Ensure the APT cache is fresh before trying to do anything and
      # install/upgrade/remove any additional packages after the python_runtime
      # resource has had its chance to do so.
      #
      %i[install upgrade remove].each do |act|
        action act do
          apt_update 'default'

          super()

          %w[3 2].each do |py|
            package "All Python #{py} system packages" do
              package_name(lazy { packages_for(py) })
              action act == :remove ? :purge : act
            end
          end
        end
      end

      action_class do
        include SnuPythonCookbook::Helpers::SnuPythonDebian
      end
    end
  end
end
