# frozen_string_literal: true

module PoisePython
  module Resources
    module PythonRuntimePip
      # Monkeypatch around poise-python's choking on Python version "2.7.15+".
      class Provider < Chef::Provider
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/LineLength
        def bootstrap_pip
          # We don't support any platforms with Python 2.6 so the logic in this
          # method to set a PIP URL based on the version can go away altogether.
          get_pip_url = new_resource.get_pip_url

          # Everything else is directly copied from poise-python.
          converge_by("Bootstrapping pip #{new_resource.version || 'latest'} from #{get_pip_url}") do
            temp = Tempfile.new(['get-pip', '.py'])
            begin
              get_pip = Chef::HTTP.new(get_pip_url).get('')
              temp.write(get_pip)
              temp.close
              boostrap_cmd = [new_resource.parent.python_binary, temp.path, '--upgrade', '--force-reinstall']
              boostrap_cmd << "pip==#{new_resource.version}" if new_resource.version
              Chef::Log.debug("[#{new_resource}] Running pip bootstrap command: #{boostrap_cmd.join(' ')}")
              user = new_resource.parent.is_a?(PoisePython::Resources::PythonVirtualenv::Resource) ? new_resource.parent.user : nil
              group = new_resource.parent.is_a?(PoisePython::Resources::PythonVirtualenv::Resource) ? new_resource.parent.group : nil
              FileUtils.chown(user, group, temp.path) if user || group
              poise_shell_out!(boostrap_cmd, environment: new_resource.parent.python_environment.merge('PIP_NO_SETUPTOOLS' => '1', 'PIP_NO_WHEEL' => '1'), group: group, user: user)
            ensure
              temp.close unless temp.closed?
              temp.unlink
            end
            new_pip_version = pip_version
            if new_resource.version && new_pip_version != new_resource.version
              Chef::Log.debug("[#{new_resource}] Pip bootstrap installed #{new_pip_version}, trying to install again for #{new_resource.version}")
              current_resource.version(new_pip_version)
              install_pip
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
