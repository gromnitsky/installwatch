# installwatch

This is a fork of `installwatch` cmd from
[CheckInstall](http://www.asic-linux.com.mx/~izto/checkinstall/index.php)
pkg.

Changes:

* apply the rel debian patches & fixes from the CI bugzilla.
* make the installation step unnecessary.
* force the wrapper script look for the .so in its dir, not in the
  system one.
* put the compilation results to `_build` dir.

Tested on Fedora 26 only. For an old changelog, see the orig repo.

## Compilation

	$ make

It creates `_build` w/ 2 files: `installwatch` &
`installwatch.so`. The former is a bash wrapper around the
latter. Copy them somewhere & put a symlink to `installwatch` script
into one of PATH dirs.

## .so manual usage

	$ LD_PRELOAD=_build/installwatch.so touch 123
	$ journalctl -ocat -n1
	3       open    /home/alex/lib/software/fork/installwatch/123   #success

## Quick start

	installwatch <command>

This monitors <command> and logs via syslog(3) every created or
modified file.

	installwatch -o <filename> <command>

does the same thing, but writing data in <filename>, which is truncated
if it already exits.

A typical usage:

	installwatch -o ~/install/foobar-x.y make install

Extra options:

	installwatch --help

## Description

Installwatch is a utility Pancrazio 'Ezio' de Mauro wrote to keep
track of created and modified files during the installation of a new
program.

It doesn't require a 'pre-install' phase because it monitors
processes while they run.

Installwatch works with every dynamically linked ELF program,
overriding system calls that cause file system alterations. Some of
such system calls are open(2) and unlink(2).

Installwatch is especially useful on RedHat, Debian and similar
distributions, where you can use a package system to keep track of
installed software.

Of course a simple 'make install' does not update the package
database, making your installation 'dirty' -- well, kind of.

Here's a typical installwatch use. After compiling your brand new
package, just type

	installwatch make install

instead of a simple make install. Then have a look at your logs.

Installwatch logs by default using syslog(3), with a `LOG_USER |
LOG_INFO` priority.

Usually the log file is /var/log/messages, but if may vary.

If you want to log on a particular file:

	installwatch -o filename make install

The log format may look ugly at first glance, but it is designed to
be easily processed by programs.

Every record ends with a newline, every field is delimited with a TAB
character (it is `^I` when you use syslog.)

The fields of a record are, in order:

	<return-value> <syscall-name> <arguments> #<comment>

So made lines are really easy to process, if arguments don't contain
TABs or pound signs.


## Credits

* Orig Installwatch author: Pancrazio 'Ezio' de Mauro <p@demauro.net>
* CheckInstall maintainer: Felipe Eduardo Sanchez Diaz Duran <izto@asic-linux.com.mx>

## License

GPLv2.
