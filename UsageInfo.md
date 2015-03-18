# Usage Details #

This generic remote library implementation is similar to the Python reference implementation in use but still slightly different. See the following for reference.

http://code.google.com/p/robotframework/wiki/RemoteLibrary

http://robotframework.googlecode.com/hg/tools/remoteserver/example/examplelibrary.py

Remote server requires the [Frontier XML-RPC Daemon Perl module](http://search.cpan.org/~kmacleod/Frontier-RPC-0.07b4/lib/Frontier/Daemon.pm). It can also be modified to use [RPC::XML::Server](http://search.cpan.org/dist/RPC-XML/lib/RPC/XML/Server.pm) module or some other XML-RPC module instead. I've found it easier to install and get up and running with the Frontier module.

Remote server also requires the [Capture Tiny Perl module](http://search.cpan.org/~dagolden/Capture-Tiny-0.21/lib/Capture/Tiny.pm) for capturing standard output and standard error to return back to Robot Framework (or your XML-RPC client).

To use it, see  [exampleremoteserver.pl](http://code.google.com/p/plrobotremoteserver/source/browse/trunk/exampleremoteserver.pl) for details.

But basically to use it, you write a Perl script to load the remote library module along with your test library module, or you can opt to instead implement your test library code in this Perl script rather than loading it externally.

Then in the Perl script, you instantiate the remote server passing it the name of the test library package/class to use, and optionally specify other parameters like server hostname/IP address, server port, and whether to allow remotely stopping server or not.

Finally, you start the server by executing the start server method. Here is an excerpt of sample code:

```
  #!/usr/bin/env perl

  #use strict;
  #use warnings;

  use lib '.'; #add local path to Perl modules, etc.
  #alternatively, for modules under lib subdirectory of local path...
  #use lib 'lib';

  #import & reference generic remote server for Robot Framework
  use RobotRemoteServer;
  # this is the robotremoteserver.pm file

  # import & reference the Robot Framework Perl test library/module (package)
  use ExampleLibrary;
  # this is the examplelibrary.pm file
  # or alternatively implement the test library in this file


  #create instance of remote server with specified library (package/module)
  my $remote_svr = new RobotRemoteServer("ExampleLibrary");

  $remote_svr->start_server();
  #listening on resource path "/RPC2"

  #ending script/module return value to append below
  1;
```

**To query or communicate with the XML-RPC (remote library) server, you have to use the web service URL format of http://host:port/RPC2.* This means that the URL to remote library for Robot Framework tests/use will be of that format. Once server is started, you can call test library keywords offered by the server from Robot Framework.**

# Testing the example remote library #

Run

> `perl exampleremoteserver.pl`

Then run the [example tests](http://robotframework.googlecode.com/svn/trunk/tools/remoteserver/example/remote_tests.html) for remote libraries/servers available from [Robot Framework](http://www.robotframework.org) project. **But do modify the remote server URL in the test case file to http://localhost:${PORT}/RPC2 before running the test.**

To test stop remote server functionality, you may wish to add a test case, test step, or test case/suite teardown like this:

| Test Case | Action | Argument |
|:----------|:-------|:---------|
| Stop Server Test | Run Keyword | Stop Remote Server |

You can alternatively test using plain XML-RPC requests following the Robot Framework spec. That's how I've initially validated functionality.

**NOTE:** If you wish to test/use stop remote server functionality, you need to enable (or not disable) that feature when instantiating the server. See code comments in [exampleremoteserver.pl](http://code.google.com/p/plrobotremoteserver/source/browse/trunk/exampleremoteserver.pl) for details. By default, the sample script has the feature disabled, you have to make a modification to it to enable.

# Perl remote library interface with the generic remote server #

The generic remote server uses Perl reflection to access the actual remote library. The remote library itself should be self contained in a "class" object or package to be loaded or referenced by the remote server. If you are not accustomed to object-oriented programming in Perl, now would be a good time.

Alternatively, you may wish to integrate the library code into the remote server and make it non-generic without using Perl reflection. This would allow for a non or less object oriented approach for those that prefer it that way.

The remote server includes keyword **stop\_remote\_server** so you don't have to implement that in the remote library.

Remote library methods should conform to [Robot Framework](http://www.robotframework.org) keyword API specification, meaning: methods should be named as **method\_name()** rather than MethodName() or methodName(); the underscore represents a space; the method is made available as a keyword in [Robot Framework](http://www.robotframework.org) named **Method Name**. Alternatively, they might not have to follow this convention, but you would have to modify the remote server to be able to translate the Robot Framework keyword naming convention to the actual Perl method naming convention when XML-RPC calls are made to **run\_keyword**.

Additionally, the library's use of data types in keyword arguments or return values should conform to the [XML-RPC](http://www.xmlrpc.com/spec) protocol and what is supported by [Robot Framework](http://www.robotframework.org).

## Designing new custom test libraries in Perl ##

For this case, you need only follow the Perl remote library interface guidelines when creating your test library for it to be callable from [Robot Framework](http://www.robotframework.org). Use [examplelibrary.pm](http://code.google.com/p/plrobotremoteserver/source/browse/trunk/examplelibrary.pm) as a model/template.

## Re-using existing Perl code or libraries for Robot Framework ##

For this case, you would need to write a wrapper module that provides the remote library functions/subroutines (or methods) encapsulated within a package (class) interface.

# Known Issues #

  * **get\_keyword\_names** may return extra Perl library methods that weren't intended to be used by [Robot Framework](http://www.robotframework.org) (e.g. internal methods), so just ignore them. Bear in mind that if you don't debug the remote library, you won't notice this issue anyways as [Robot Framework](http://www.robotframework.org) doesn't explicitly dump a list of available keywords for the end user to see, except for library documentation generation with libdoc.py ([Issue 4](http://code.google.com/p/plrobotremoteserver/issues/detail?id=4))

# Tips for Debugging #

  * You can use a REST client (like popular browser extensions) to pass correct [XML-RPC](http://www.xmlrpc.com/spec) requests (an HTTP POST with data payload in XML-RPC format) and validate correct XML response from remote library.

  * You can use [Robot Framework](http://www.robotframework.org) tests to make the XML-RPC calls and validate correct responses, etc. if you are not good with XML-RPC messaging.

  * For library related issues, you can build other Perl scripts to call library for local execution rather than over XML-RPC server to make sure library works correctly. See [exampleremoteserver.pl](http://code.google.com/p/plrobotremoteserver/source/browse/trunk/exampleremoteserver.pl) for reference, which makes sample local execution calls to the remote library methods/functions.