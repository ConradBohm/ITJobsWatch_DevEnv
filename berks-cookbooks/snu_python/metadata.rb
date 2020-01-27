# frozen_string_literal: true

name 'snu_python'
maintainer 'Socrata Engineering'
maintainer_email 'sysadmin@socrata.com'
license 'Apache-2.0'
description 'Installs/configures snu_python'
long_description 'Installs/configures snu_python'
version '1.2.4'
chef_version '>= 12.14'

source_url 'https://github.com/socrata-cookbooks/snu_python'
issues_url 'https://github.com/socrata-cookbooks/snu_python/issues'

depends 'poise-python'

supports 'ubuntu'
supports 'debian'
