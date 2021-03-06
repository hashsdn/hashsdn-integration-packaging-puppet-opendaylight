# OpenDaylight

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)

- [What `opendaylight` affects](#what-opendaylight-affects)
- [Beginning with `opendaylight`](#beginning-with-opendaylight)

4. [Usage](#usage)

- [Karaf Features](#karaf-features)
- [RPM Repo](#rpm-repo)
- [Deb Repo](#deb-repo)
- [Ports](#ports)
- [Log Verbosity](#log-verbosity)
- [Enabling ODL HA](#enabling-odl-ha)

5. [Reference ](#reference)
6. [Limitations](#limitations)
7. [Development](#development)
8. [Release Notes/Contributors](#release-notescontributors)

## Overview

Puppet module that installs and configures the [OpenDaylight Software Defined
Networking (SDN) controller][1].

## Module Description

Deploys OpenDaylight to various OSs either via an RPM or a Deb.

All OpenDaylight configuration should be handled through the ODL Puppet
module's [params](#parameters).

By default, the master branch installs OpenDaylight from the latest testing
RPM repository or from the latest stable Deb repository depending on the OS.
The stable/<release> branches install corresponding older ODL versions.

## Setup

### What `opendaylight` affects

- Installs Java, which is required by ODL.
- Creates `odl:odl` user:group if they don't already exist.
- Installs [OpenDaylight][1], including a systemd unit file.
- Manipulates OpenDaylight's configuration files according to the params
  passed to the `::opendaylight` class.
- Starts the `opendaylight` systemd service.

### Beginning with `opendaylight`

Getting started with the OpenDaylight Puppet module is as simple as declaring
the `::opendaylight` class.

## Usage

The most basic usage, passing no parameters to the OpenDaylight class, will
install and start OpenDaylight with a default configuration.

```puppet
class { 'opendaylight':
}
```

### Karaf Features

To set extra Karaf features to be installed at OpenDaylight start time, pass
them in a list to the `extra_features` param. The extra features you pass will
typically be driven by the requirements of your ODL install. You'll almost
certainly need to pass some.

```puppet
class { 'opendaylight':
  extra_features => ['odl-netvirt-openstack'],
}
```

OpenDaylight normally installs a default set of Karaf features at boot. They
are recommended, so the ODL Puppet mod defaults to installing them. This can
be customized by overriding the `default_features` param. You shouldn't
normally need to do so.

```puppet
class { 'opendaylight':
  default_features => ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'],
}
```

### RPM Repository

The `rpm_repo` param can be used to configure which RPM repository
OpenDaylight is installed from.

```puppet
class { 'opendaylight':
  rpm_repo => 'opendaylight-61-release',
}
```

The naming convention follows the naming convention of the CentOS Community
Build System, which is where upstream ODL hosts its RPMs. The
`opendaylight-61-release` example above would install OpenDaylight Carbon SR1
6.1.0 from the [nfv7-opendaylight-61-release][2] repo. Repo names ending in
`-release` will always contain well-tested, officially released versions of
OpenDaylight. Repos ending in `-testing` contain frequent, but unstable and
unofficial, releases. The ODL version given in repo names shows which major
and minor version it is pinned to. The `opendaylight-61-release` repo will
always provide OpenDaylight Carbon SR1 6.1, whereas `opendaylight-4-release`
will provide the latest release with major version 6 (which could include
Service Releases, like SR2 6.2).

For additional information about ODL RPM repos, see the [Integration/Packaging
RPM repositories documentation][3].

This is only read for Red Hat-family operating systems.

### Deb Repository

The `deb_repo` param can be used to configure which Deb repository
OpenDaylight is installed from.

```puppet
class { 'opendaylight':
  deb_repo => 'ppa:odl-team/carbon',
}
```

The naming convention is same as the naming convention of Launchpad PPA's,
which is where ODL .debs are hosted. The `ppa:odl-team/carbon` example above
would install OpenDaylight Carbon from the [boron launchpad repo][4].

This is only read for Debian-family operating systems.

### Ports

To change the port on which OpenDaylight's northbound listens for REST API
calls, use the `odl_rest_port` param.

```puppet
class { 'opendaylight':
  odl_rest_port => '8080',
}
```

### Log Verbosity

It's possible to define custom logger verbosity levels via the `log_levels`
param.

```puppet
class { 'opendaylight':
  log_levels => { 'org.opendaylight.ovsdb' => 'TRACE', 'org.opendaylight.ovsdb.lib' => 'INFO' },
}
```

### Enabling ODL HA

To enable ODL HA, use the `enable_ha` flag. It's disabled by default.

When `enable_ha` is set to true the `ha_node_ips` should be populated with the
IP addresses that ODL will listen on for each node in the HA cluster and
`odl_bind_ip` should be set with the IP address from `ha_node_ips` configured
for the particular node that puppet is configuring as part of the
HA cluster.

By default a single ODL instance will become the leader for the entire
datastore.  In order to distribute the datastore over multiple ODL instances,
`ha_db_modules` parameter may be specified which will include the modules
desired to separate out from the default shard, along with the Yang namespace
for that module.

```puppet
class { 'opendaylight':
  enable_ha     => true,
  ha_node_ips   => ['10.10.10.1', '10.10.10.1', '10.10.10.3'],
  odl_bind_ip   => 0,
  ha_db_modules => {'default' => false, 'topology' => 'urn:opendaylight:topology'}
}
```

## Reference

### Classes

#### Public classes

- `::opendaylight`: Main entry point to the module. All ODL knobs should be
  managed through its params.

#### Private classes

- `::opendaylight::params`: Contains default `opendaylight` class param values.
- `::opendaylight::install`: Installs ODL from an RPM or a Deb.
- `::opendaylight::config`: Manages ODL config, including Karaf features and
  REST port.
- `::opendaylight::service`: Starts the OpenDaylight service.

### `::opendaylight`

#### Parameters

##### `default_features`

Sets the Karaf features to install by default. These should not normally need
to be overridden.

Default: `['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']`

Valid options: A list of Karaf feature names as strings.

##### `extra_features`

Specifies Karaf features to install in addition to the defaults listed in
`default_features`.

You will likely need to customize this to your use-case.

Default: `[]`

Valid options: A list of Karaf feature names as strings.

##### `odl_rest_port`

Specifies the port for the ODL northbound REST interface to listen on.

Default: `'8080'`

Valid options: A valid port number as a string or integer.

##### `rpm_repo`

OpenDaylight CentOS CBS repo to install RPM from (opendaylight-6-testing,
opendaylight-6-release, ...).

##### `deb_repo`

OpenDaylight Launchpad PPA repo to install .deb from (ppa:odl-team/boron,
ppa:odl-team/carbon, ...).

##### `log_levels`

Custom OpenDaylight logger verbosity configuration.

Default: `{}`

Valid options: A hash of loggers to log levels.

```
{ 'org.opendaylight.ovsdb' => 'TRACE', 'org.opendaylight.ovsdb.lib' => 'INFO' }
```

Valid log levels are TRACE, DEBUG, INFO, WARN, and ERROR.

The above example would add the following logging configuration to
`/opt/opendaylight/etc/org.ops4j.pax.logging.cfg`.

```
# Log level config added by puppet-opendaylight
log4j.logger.org.opendaylight.ovsdb = TRACE

# Log level config added by puppet-opendaylight
log4j.logger.org.opendaylight.ovsdb.lib = INFO
```

To view loggers and their verbosity levels, use `log:list` at the ODL Karaf shell.

```
opendaylight-user@root>log:list
Logger                     | Level
----------------------------------
ROOT                       | INFO
org.opendaylight.ovsdb     | TRACE
org.opendaylight.ovsdb.lib | INFO
```

The main log output file is `/opt/opendaylight/data/log/karaf.log`.

##### `log_max_size`

Maximum size of OpenDaylight's log file, `/opt/opendaylight/data/log/karaf.log`.

Once this size is reached, the log will be rolled over, with up to
`log_max_rollover` log rollovers preserved in total.

Default: `10GB`

Valid options: A valid size as a string with unit specified.

##### `log_max_rollover`

Maximum number of OpenDaylight karaf.log rollovers to keep.

Note that if this is set to 1, log rollovers will result in loosing newly
logged data. It's recommended to use values greater than one to prune from
the end of the log.

Default: `2`

Valid options: An integer greater than 0.

##### `enable_ha`

Enable or disable ODL High Availablity.

Default: `false`

Valid options: The boolean values `true` and `false`.

Requires: `ha_node_ips`, `odl_bind_ip`

The ODL Clustering XML for HA are configured and enabled.

##### `ha_node_ips`

Specifies the IPs that are part of the HA cluster enabled by `enable_ha`.

Default: \[]

Valid options: An array of IP addresses `['10.10.10.1', '10.10.10.1', '10.10.10.3']`.

Required by: `enable_ha`

##### `ha_db_modules`

Specifies the modules to use for distributing and sharding the ODL datastore.

Default: `{'default'=> false}`

Valid options: A hash of module and Yang namespace for the module (default has no namespace).

Requires: `enable_ha`

##### `ha_node_index`

Specifies the index of the IP for the node being configured from the array `ha_node_ips`.

Default: ''

Valid options: Index of a member of the array `ha_node_ips`: `0`.

This parameter is now deprecated and is no longer used.

##### `snat_mechanism`

Specifies the mechanism to be used for SNAT.

Default: `controller`

Valid options: `conntrack`, `controller`

##### `vpp_routing_node`

Specifies the routing node for VPP deployment. A non-empty string will create config file
org.opendaylight.groupbasedpolicy.neutron.vpp.mapper.startup.cfg with routing-node set.

Default: `''`

Valid options: A valid host name to a VPP node handling routing.

##### `java_opts`

Specifies the Java options to run ODL with as a string.

Default: `'-Djava.net.preferIPv4Stack=true'`

Valid options: A string of valid Java options.

##### `username`

Specifies the username to set for admin role in ODL.

Default: `'admin'`

Valid options: A username string.

##### `password`

Specifies the password to set for admin role in ODL.

Default: `'admin'`

Valid options: A password string.

## Limitations

- Tested on CentOS 7 and Ubuntu 16.04.
- Fedora is allowed but not well-tested, no Beaker coverage.

## Development

We welcome contributions and work to make them easy!

See [CONTRIBUTING.markdown][5] for details about how to contribute to the
OpenDaylight Puppet module.

## Release Notes

See the [CHANGELOG][6] for information about releases.

[1]: http://www.opendaylight.org/ "OpenDaylight homepage"

[2]: http://cbs.centos.org/repos/nfv7-opendaylight-61-release/x86_64/os/Packages/ "OpenDaylight Carbon SR1 CentOS CBS repo"

[3]: http://docs.opendaylight.org/en/latest/submodules/integration/packaging/docs/rpms.html#repositories "ODL RPM repo docs"

[4]: https://launchpad.net/~odl-team/+archive/ubuntu/carbon "ODL Carbon Deb repo"

[5]: https://git.opendaylight.org/gerrit/gitweb?p=integration/packaging/puppet-opendaylight.git;a=blob;f=CONTRIBUTING.markdown "Contributing docs"

[6]: https://git.opendaylight.org/gerrit/gitweb?p=integration/packaging/puppet-opendaylight.git;a=blob;f=CHANGELOG "Chagelog"
