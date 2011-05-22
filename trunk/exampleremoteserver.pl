#!/usr/bin/env perl

#use strict;
#use warnings;

use lib '.'; #add local path to Perl modules, etc.
#alternatively, for modules under lib subdirectory of local path...
#use lib 'lib';

#import & reference generic remote server for Robot Framework
use RobotRemoteServer;

# import & reference the Robot Framework Perl test library/module
use ExampleLibrary;
#or alternatively implement the test library in this file

#create instance of remote server with specified library
my $remote_svr = new RobotRemoteServer("ExampleLibrary");

#alternatively, specified like...
#my $remote_svr = new RobotRemoteServer("ExampleRemoteLibrary.pm");
#my $remote_svr = new RobotRemoteServer("ExampleRemoteLibrary.pl");

#set address & port like this
#my $remote_svr = new RobotRemoteServer("ExampleRemoteLibrary","my.domain.com",8080);

#disable stopping of remote server remotely like this:
#my $remote_svr = new RobotRemoteServer("ExampleRemoteLibrary","localhost",8080,0);
#by default, stopping server remotely is enabled (e.g. value of 1)

#DEBUG showing details of local execution
print "Debugging info: showing details of local execution...\n\n";
print "keywords:\n";
my @kws = $remote_svr->get_keyword_names();
foreach(@kws){
  print $_."\n";
}
print "\n";

print "running keywords:\n";
print "\n";

my @stat = $remote_svr->run_keyword("strings_should_be_equal","hello","world");
foreach(@stat){
  while ( my ($key, $value) = each(%$_) ) {
        print "$key => $value\n";
    }
}
print "\n";

my @stat = $remote_svr->run_keyword("count_items_in_directory","C:\\Temp");
foreach(@stat){
  while ( my ($key, $value) = each(%$_) ) {
        print "$key => $value\n";
    }
}
print "\n";

#This has been tested to work offline. Comment out so can test server online, 
#else this will shut down the server already before it starts.
my @stat = $remote_svr->run_keyword("stop_remote_server");
foreach(@stat){
  while ( my ($key, $value) = each(%$_) ) {
        print "$key => $value\n";
    }
}
print "\n";

#start remote server
print "Robot remote server started. Stop server with Ctrl+C, kill, etc. or XML-RPC method 'run_keyword' with parameter 'stop_remote_server'\n\n";

print "Debugging info: here is where we have XML-RPC problems with Perl reflection once try use XML-RPC. As can see from runtime demo above, no issues using reflection locally.\n\n";

$remote_svr->start_server();

#ending script/module return value to append below
1;
