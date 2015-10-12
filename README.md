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

# Running the Master

```
$ cd rust-buildbot/master
$ buildbot start
```

# Adding a new builder

This requires some digging in `master.cfg`. If the new builder will be gated,
you'll also have to add it in `/home/rustbuild/homu/cfg.toml`.

* Choose the new builder's name. 

    * If it runs tests with optimizations enabled, the name will contain
      `-opt`. 

    * If the tests are run without optimizations, the name should contain
      `-nopt-t`. 

    * If you're toggling a new option, pick the unique string that represents
      the option at hand.

* Add the new builder name to the `auto_platforms_dev` and
  `auto_platforms_prod` lists.

* Add the new builder to `dist_nogate_platforms` (or the alternative for
  gated). Its name will have acquired an `auto-` prefix at this point.

* Under `for p in auto_platforms`, add logic to check for the unique string
  from the name. Yes, it's terrible. I'm sorry.

* Under the next `for p in auto_platforms`, set your new flag according to the
  value you read from the unique string in the previous step.

Pull requests to simplify this workflow are welcome. 

# It's broken!

Sometimes the queue gets stuck. The most obvious symptom is if a PR takes
substantially longer than usual to build. 

First, check Homu's queue [here](http://buildbot.rust-lang.org/homu/queue/rust). 
If Homu hasn't seen the PR, one can repeat the `r+`. If that doesn't work,
restart Homu on the buildmaster. 

If the PR is listed as "pending" in the Homu queue, check for pending jobs on
[the grid](http://buildbot.rust-lang.org/grid?branch=auto&width=10). If there
are no pending jobs in the grid, kick Homu by having someone with permissions
on the repo say "@bors: retry force" on the PR that's stuck. 

If the grid is aware of the jobs, check for lost buildslaves. When a builder
gets lost, its name will be purple and its status will include "slave lost".
This means that either the host needs to be booted or the buildbot process on
it needs to be restarted. 

If the above steps fail, restart the Buildbot process on the production
buildmaster.

# Testing Locally

## `master.cfg.txt`

To do things with this Buildbot on your local machine, you'll need to create
the file `master/master.cfg.txt`. `master.cfg` reads secrets out of it at
startup. 

```
env prod
master_addy 11.22.333.4444:5678
git_source git://github.com/rust-lang/rust.git
cargo_source git://github.com/rust-lang/cargo.git
packaging_source git://github.com/rust-lang/rust-packaging.git
s3_addy s3://your-bucket-name-here
s3_cargo_addy s3://your-other-bucket-name-here
homu_secret RFqnZtXnRhD66qv11WOGIkuGn2YzvylOcxlqqXZmSq4RaLpXfb
dist_server_addy http://your-bucket-name.here.s3-website-aws-region.amazonaws.com
```

* `master_addy` is the address and port where buildmaster is running
* `s3_addy` and `s3_cargo_addy` are buckets where artefacts will get uploaded
* `homu_secret` is a string that you can get from `pwgen -s 64 -n 1` or so,
   which also appears in `~/rustbuild/homu/cfg.toml` under `repo.rust.buildbot`
   and `repo.cargo.buildbot`. 
* `dist_server_addy` is the url of that bucket where stuff gets uploaded

# License

This software is distributed under the terms of both the MIT license
and/or the Apache License (Version 2.0), at your option.

See [LICENSE-APACHE](LICENSE-APACHE), [LICENSE-MIT](LICENSE-MIT) for details.
