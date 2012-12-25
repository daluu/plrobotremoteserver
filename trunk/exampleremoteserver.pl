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
#my $remote_svr = new RobotRemoteServer("ExampleLibrary");

#alternatively, specified like...
#my $remote_svr = new RobotRemoteServer("ExampleLibrary.pm");
#my $remote_svr = new RobotRemoteServer("ExampleLibrary.pl");

#set address & port like this
#my $remote_svr = new RobotRemoteServer("ExampleLibrary","my.domain.com",8080);

#disable stopping of remote server remotely like this:
my $remote_svr = new RobotRemoteServer("ExampleLibrary","localhost",8270,0);
#by default, stopping server remotely is enabled (e.g. value of 1)

#DEBUG showing details of local execution / self test
print "\n***Debugging info: showing details of local execution self test...***\n";
print "(Comment out this code block in script if not needed)\n\n";
print "keywords:\n";
print "---------\n";
my $kws = $remote_svr->get_keyword_names();
foreach(@$kws){
  print $_."\n";
}
print "\n";

print "running keywords:\n";
print "-----------------\n";
print "\n";

my $stat = $remote_svr->run_keyword("strings_should_be_equal","hello","world");
print "output for 'strings_should_be_equal' with 'hello' and 'world' as arguments...\n";
while ( my ($key, $value) = each(%$stat) ) {
  print "$key => $value\n";
}
print "\n";

my $stat = $remote_svr->run_keyword("strings_should_be_equal","hello","hello");
print "output for 'strings_should_be_equal' with 'hello' and 'hello' as arguments...\n";
while ( my ($key, $value) = each(%$stat) ) {
  print "$key => $value\n";
}
print "\n";

my $stat = $remote_svr->run_keyword("count_items_in_directory",".");
print "output for 'count_items_in_directory' with current working directory as argument...\n";
while ( my ($key, $value) = each(%$stat) ) {
  print "$key => $value\n";
}
print "\n";

# This has been tested to work offline. Comment out so can test server online, 
# else this will shut down the server already before it starts.
my $stat = $remote_svr->run_keyword("stop_remote_server");
print "attempting to execute stop_remote-server, output is...\n";
while ( my ($key, $value) = each(%$stat) ) {
  print "$key => $value\n";
}
print "\n";

print "***Now starting server for actual use or debugging...***\n\n";

#start remote server
print "Robot remote server started. Stop server with Ctrl+C, kill, etc. or XML-RPC method 'run_keyword' with parameter 'stop_remote_server'\n\n";

$remote_svr->start_server();

#ending script/module return value to append below
1;
