# Overview #

**NOTE: the project, in terms of any code updates/fixes, has been moved to [Github](https://github.com/daluu/plrobotremoteserver) now.** This repo will be for the current/old code & documentation. Since usage & interest in the Perl remote server has picked up, I want to make it easier for others to contribute patches and code changes, and/or forking a copy of the project for themselves.

This project offers a generic remote server for [Robot Framework](http://www.robotframework.org), implemented in Perl, for use in creating remote libraries. It can alternatively be used for other purposes outside of [Robot Framework](http://www.robotframework.org).

Remote server requires the [Frontier XML-RPC Daemon Perl module](http://search.cpan.org/~kmacleod/Frontier-RPC-0.07b4/lib/Frontier/Daemon.pm). It can also be modified to use [RPC::XML::Server](http://search.cpan.org/dist/RPC-XML/lib/RPC/XML/Server.pm) module or some other XML-RPC module instead. I've found it easier to install and get up and running with the Frontier module.

Remote server also requires the [Capture Tiny Perl module](http://search.cpan.org/~dagolden/Capture-Tiny-0.21/lib/Capture/Tiny.pm) for capturing standard output and standard error to return back to Robot Framework (or your XML-RPC client).

See UsageInfo on how to use the code here.

# Downloads #

Download the files from the [source repository](http://code.google.com/p/plrobotremoteserver/source/browse/#svn%2Ftrunk) or use Subversion checkout.

# News #

  * May 9, 2014 - project moved/clone to [Github](https://github.com/daluu/plrobotremoteserver). Future updates will go there.
  * December 24, 2012 - fixed [issue 1](https://code.google.com/p/plrobotremoteserver/issues/detail?id=1).
  * June 3, 2011 - finally got remote server fully working. Thanks to code contributions / help from [ysth at stackoverflow.com](http://stackoverflow.com/questions/6086584/problems-with-perl-xml-rpc-in-combination-with-perl-reflection). Please help test out the server. Note that I consider this Beta quality/release at this time.

# Contact #

For now, please direct all inquiries to the project admin. You could also post inquiries to [Robot Framework Users Google Group](http://groups.google.com/group/robotframework-users) as I am a member of that group and periodically check it. If there is enough inquiry activity, I may start a Google Group, etc. for it.