#!/usr/bin/env perl

################################################################################
# This library is free software; you can redistribute it and/or modify it under 
# the terms of the GNU Lesser General Public License as published by the Free 
# Software Foundation; either version 2.1 of the License, or (at your option) 
# any later version.

# This library is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details.

# You should have received a copy of the GNU Lesser General Public License along 
# with this library; if not, write to the Free Software Foundation, Inc., 
# 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
################################################################################

# Author: David Luu

# This is a demo script showing runtime loading of an external test library into
# remote server for execution to be called by Robot Framework over XML-RPC.

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

#DEBUG blocks showing local execution rather than via XML-RPC
print "Debugging info...\n\n";
print "keywords:\n";
my @res = $remote_svr->get_keyword_names();
foreach (@res){
	print $_."\n";
}
print "\n";

print "runkeyword:\n";
print "\n";

print "string equal:\n";
print "\n";
my @stat = $remote_svr->run_keyword("strings_should_be_equal","hello","world");
foreach (@stat){
	print $_."\n";
}
print "\n";

print "count dir:\n";
print "\n";
my @stat = $remote_svr->run_keyword("count_items_in_directory","C:\\Temp");
foreach (@stat){
	print $_."\n";
}
print "\n";

#This has been tested to work offline. Comment out so can test server online, 
#else this will shut down the server already before it starts.
#my @stat = $remote_svr->run_keyword("stop_remote_server");
#foreach (@stat){
#	print $_."\n";
#}
print "\n";

#start remote server
print "Robot remote server started. Stop server with Ctrl+C, kill, etc. or XML-RPC method 'run_keyword' with parameter 'stop_remote_server'\n";
$remote_svr->start_server();
#now can test with XML-RPC requests to server

#ending script/module return value to append below
1;
