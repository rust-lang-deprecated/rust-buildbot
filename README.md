# The Rust Project's buildbot config

This is the code for the buildbot instance used by Rust at
http://buildbot.rust-lang.org/builders. It is currently not in a
condition that allows people to easily set up their own instances.

# Slave configuration

Slaves communicate with buildbot through an ssh tunnel for which
you'll need the stunnel tool. Use whichever version of of the
buildslave software the other slaves are running.

This repo includes a configure script for creating the stunnel
configuration. From within the repo, run 'setup-slave.sh', enter the
name, password, and master address that you were provided. This
creates the stunnel configuration file called
`rust-buildbot-slave-stunnel-final.conf`.

The first time you run this script it will start stunnel and the
buildslave, but typically you would run stunnel and buildslave at
reboot using cron:

```
> stunnel rust-buildbot-slave-stunnel-final.conf && buildslave restart slave
```

# License

This software is distributed under the terms of both the MIT license
and/or the Apache License (Version 2.0), at your option.

See [LICENSE-APACHE](LICENSE-APACHE), [LICENSE-MIT](LICENSE-MIT) for details.
