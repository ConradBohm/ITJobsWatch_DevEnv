# Snu Python Cookbook README

[![Cookbook Version](https://img.shields.io/cookbook/v/snu_python.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/socrata-cookbooks/snu_python.svg)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/snu_python
[travis]: https://travis-ci.org/socrata-cookbooks/snu_python

A cookbook to perform an opinionated installation of Python using poise-python.

## Requirements

This cookbook is continously tested against a matrix of Chef versions and platforms. For the full list, see the output of `chef exec microwave list`.

Additional platform support may be added in the future, but Python in RHEL-land seems to get real scary real fast.

## Usage

Add the default recipe to your node's run list and/or declare instances of the included resources in a recipe of your own.

## Recipes

***default***

Installs Python 2 and 3 and some default packages using the `snu_python` resource

## Attributes

N/A

## Resources

***snu_python***

A wrapper around the `python_runtime` resource to install both Python 2 and 3 as well as any supporting packages (e.g. the python3 package that manages `/usr/local/bin/python3` on Debian platforms) and some default packages from PIP.

Syntax:

```ruby
snu_python 'default' do
  python3_packages %w[requests]
  python2_packages %w[requests]
  action :install
end
```

Actions:

| Action     | Description                                         |
|------------|-----------------------------------------------------|
| `:install` | Install Python 2 and 3 and friends                  |
| `:upgrade` | Upgrade Python 2 and 3 and friends                  |
| `:remove`  | Uninstall Python 2 and 3 and all installed packages |

Properties:

| Property         | Default      | Description                        |
|------------------|--------------|------------------------------------|
| python3_packages | %w[requests] | Packages to install under Python 3 |
| python2_packages | %w[requests] | Packages to install under Python 2 |
| action           | `:install`   | The action to perform              |

## Maintainers

- Jonathan Hartman <jonathan.hartman@socrata.com>
