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

# RobotFramework Perl implementation of generic remote library server.
# Based on RobotFramework spec at
# http://code.google.com/p/robotframework/wiki/RemoteLibrary
# http://robotframework.googlecode.com/svn/tags/robotframework-2.5.6/doc/userguide/RobotFrameworkUserGuide.html#remote-library-interface
# http://robotframework.googlecode.com/svn/tags/robotframework-2.5.6/doc/userguide/RobotFrameworkUserGuide.html#dynamic-library-api

# Uses Perl reflection to serve the dynamically loaded remote library/module
# You may alternatively modify this starting code base to natively integrate
# your Perl test library code into the server rather than load it dynamically
# with reflection.

# Development notes: other useful info for making working server
# http://www.codeproject.com/KB/perl/camel_poop.aspx
# http://www.netalive.org/tinkering/serious-perl/#oop_constructors

package RobotRemoteServer;
#use strict;
#use warnings;

use Frontier::Daemon; # XML-RPC server library
# get from CPAN...
# http://search.cpan.org/~kmacleod/Frontier-RPC-0.07b4/lib/Frontier/Daemon.pm
# alternative XML-RPC module choice(s) for implementing the server...

# http://www.debian-administration.org/articles/422
# http://www.blackperl.com/RPC::XML/
# http://search.cpan.org/dist/RPC-XML/

# Other possible modules to import for use, for code reflection
# Class::MOP, Moose, Class::Inspector, Class:Sniff
# http://stackoverflow.com/questions/1021713/how-do-i-loop-over-all-the-methods-of-a-class-in-perl
# http://stackoverflow.com/questions/607282/whats-the-best-way-to-discover-all-subroutines-a-perl-module-has
# Which works or works best for this particular server design? See code below.

sub new {
	my ($class, $lib, $addr, $port) = @_;
	#set default host and port per Robot Framework spec
	$addr = 'localhost' unless defined($addr);
	$port = 8270 unless defined($port);
	my $self = {
		_addr => $addr,
		_port => $port,
		_lib => $lib
	};
	bless $self, $class;
	return $self;
}
# FYI, default URL for XML-RPC server is http://host:port/RPC2

#accessor methods for members
sub address {
    my ( $self, $addr ) = @_;
    $self->{_addr} = $addr if defined($addr);
    return ( $self->{_addr} );
}

sub port {
    my ( $self, $port ) = @_;
    $self->{_port} = $port if defined($port);
    return ( $self->{_port} );
}

sub library {
    my ( $self, $lib ) = @_;
    $self->{_lib} = $lib if defined($lib);
    return ( $self->{_lib} );
}

#Robot Framework remote server API methods, per the spec
sub get_keyword_names {
	#based on code snippet from
	#http://stackoverflow.com/questions/1021713/how-do-i-loop-over-all-the-methods-of-a-class-in-perl
	my ($self) = @_;
	my $class = $self->{_lib}; #keyword = class/module/package
	eval "require $class";
	no strict 'refs';
	my @methods = grep { defined &{$class . "::$_"} } keys %{$class . "::"};
	push @methods, get_keyword_names($_) foreach @{$class . "::ISA"};
	#add stop server method, which is implemented in the server for use
	#by Robot Framework, so test library doesn't have to implement this
	#method
	push @methods, "stop_remote_server";
	return @methods; #return array list of keyword names
}

sub run_keyword {
	my ($self, $method, @rpcargs) = @_; #the keyword/method to run
	
	#define return data structure, which should be a XML-RPC struct
	
	#run keyword, & get return code, if any
	#run keyword within eval, etc. so can catch a "die" exception call
	#in which case set status = fail, & pass along exception message
	#as return data structure to Robot Framework

	#since Perl has no concept of a real boolean (any positive or negative?
	#number will be true, status always = pass, except for exceptions.
	
	#output & stack trace generally blank until we can figure out
	#how to redirect output and pass along exception stack, etc.

	my %keyword_result = (
		status => 'PASS',
		output => '',
		error => '',
		traceback => '',
		Return => '',
	);
    
	if($method eq "stop_remote_server"){
		#once server working right, need to change code here to use 
		#threads, so spawned thread will shutdown server after delay of 
		#1 minute, etc. In the meantime, main thread will return XML-RPC 
		#response to Robot Framework, per spec.
		
		$self->teardown(); #call another method to return result 1st
		#sleep 60;
		die ("Stop Remote Server called by Robot Framework.");
	}
	#based on code snippet from
	#http://en.wikipedia.org/wiki/Reflection_(computer_programming)#Perl
	my $class = $self->{_lib};
	my $retval;
	
	#DEBUG block
	print "RPC args:\n";
	foreach(@rpcargs){
		print $_."\n";
	}
	print "\n";
	
	eval{$retval = $class->$method(@rpcargs);};
	
	if ($@){ #die/exception occurred
		$keyword_result{status} = "FAIL";
		$keyword_result{output} = $@;
		$keyword_result{error} = $@;
		$keyword_result{traceback} = $@;
	}
	#check retval for "undef", in which case, set return code = blank.
	#Otherwise, set return code to retval.
	$keyword_result{Return} = $retval if defined($retval);
	
	return \%keyword_result;
}

#internal remote server methods
#based on code snippet from
#http://www.ibm.com/developerworks/webservices/library/ws-xpc1/#l3
sub start_server {
	my ($self) = @_;
	my $svr = Frontier::Daemon->new(
                                         methods => {
					             get_keyword_names => \&get_keyword_names,
						     run_keyword => \&run_keyword,
			                           },
					 LocalAddr => $self->{_addr},
			                 LocalPort => $self->{_port},
			                );
	#return $svr;
}

#helper method to shutdown server per Robot Framework spec
sub teardown {
	my %shutdown_result = (
		status => 'PASS',
		output => 'Remote server shut down.',
		error => '',
		traceback => '',
		Return => '',
	);
	return \%shutdown_result;
}

#additional non-required and not implemented server interface methods,
#per Robot Framework spec...

#sub get_keyword_arguments{
#	my ($self, $method) = @_;
	#use reflection? to return (array) list of arguments/parameters that
	#the specified keyword (method) takes
#}

#sub get_keyword_documentation{
#	my ($self, $method) = @_;
	#use reflection? to return a string containing documentation for the 
	#specified keyword (method)
#}

#ending script/module return value to append below
1;
