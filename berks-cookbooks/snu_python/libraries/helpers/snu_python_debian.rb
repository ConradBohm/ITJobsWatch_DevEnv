# frozen_string_literal: true

#
# Cookbook:: snu_python
# Library:: helpers/snu_python_debian
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

module SnuPythonCookbook
  module Helpers
    # Helpers for dealing with Python packages on Debian platforms.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    module SnuPythonDebian
      # Keep track of more packages than what poise-python alone covers. This
      # enables installing the top-level python/python3 packages that manage
      # e.g. /usr/bin/python3 and uninstalling all the dependencies they pull
      # in without any worries about an autoremove unintentionally killing
      # unrelated packages.
      PACKAGES ||= %w[
        python%<major>s
        python%<major>s-dev
        python%<major>s-minimal
        libpython%<major>s-stdlib
        libpython%<major>s-dev
        python%<major_minor>s-minimal
        libpython%<major_minor>s
        libpython%<major_minor>s-stdlib
        libpython%<major_minor>s-minimal
        libpython%<major_minor>s-dev
      ].freeze

      #
      # Build the list of packages for this platform that should be managed.
      #
      # @param [String] python the major python version
      #
      # @return [Array<String>] an array of package names
      #
      def packages_for(python)
        pkgs = PACKAGES.map do |p|
          format(p,
                 major: python == '2' ? '' : python,
                 major_minor: major_minor_for(python))
        end

        pkgs + platform_specific_packages_for(python)
      end

      #
      # Return any additional, additional packages specific to this platform.
      # Right now, that just means distutils for Python 3 on Ubuntu 18.04 and
      # Debian 10.
      #
      # @param [String] python the major python version
      #
      # @return [Array<String>] an array of package names
      #
      def platform_specific_packages_for(python)
        req = Gem::Requirement.new(
          { 'ubuntu' => '>= 18.04', 'debian' => '>= 10' }[node['platform']]
        )
        ver = Gem::Version.new(node['platform_version'])
        return [] unless python == '3' && req.satisfied_by?(ver)

        %W[
          python3-distutils
          python#{major_minor_for(python)}-distutils
          python-pip-whl
        ]
      end

      #
      # Check the APT cache to find the major.minor version of a major Python
      # on this platform.
      #
      # @param [String] python the Python major version as a string
      #
      # @return [String] the Python major.minor version
      #
      def major_minor_for(python)
        @major_minor_for ||= {}
        @major_minor_for[python] ||= begin
          pkg = { '3' => 'python3', '2' => 'python' }[python]

          line = shell_out!("apt-cache show #{pkg}").stdout.lines.find do |l|
            l.split(':')[0] == 'Depends'
          end
          line.split[1].gsub(/^python/, '').strip
        end
      end
    end
  end
end
