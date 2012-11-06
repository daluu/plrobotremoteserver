#!/usr/bin/env perl

################################################################################
# Perl generic remote library server for Robot Framework
# From http://code.google.com/p/plrobotremoteserver/
# Licensed under the GNU Lesser GPL
# http://www.gnu.org/licenses/lgpl.txt
# @author David Luu
################################################################################

package RobotRemoteServer;
#use strict;
#use warnings;

use Frontier::Daemon; #XML-RPC server library
#http://search.cpan.org/~kmacleod/Frontier-RPC-0.07b4/lib/Frontier/Daemon.pm

#alternatively can try implementing this server
#with a different XML-RPC server library:

#use RPC::XML::Server;
#http://search.cpan.org/dist/RPC-XML/lib/RPC/XML/Server.pm

use threads; #for stop remote server
use POSIX strftime; #for timestamps
 
sub new {
	my ($class, $lib, $addr, $port, $enableStopSvr) = @_;
	$addr = 'localhost' unless defined($addr);
	$port = 8270 unless defined($port);
	$enableStopSvr = 1 unless defined($enableStopSvr);
	my $self = {
		_addr => $addr,
		_port => $port,
		_lib => $lib,
		_enableStopSvr => $enableStopSvr
	};
	bless $self, $class;
	return $self;
}

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

#Robot Framework remote server API methods
sub get_keyword_names {
	#based on code snippet from
	#http://stackoverflow.com/questions/1021713/how-do-i-loop-over-all-the-methods-of-a-class-in-perl
	my ($self) = @_;
	my $class = $self->{_lib}; #keyword = class/module/package
	eval "require $class";
	no strict 'refs';
	my @methods = grep { defined &{$class . "::$_"} } keys %{$class . "::"};
	push @methods, get_keyword_names($_) foreach @{$class . "::ISA"};
	push @methods, "stop_remote_server";
	return \@methods;
}

sub run_keyword {
	my ($self, $method, @rpcargs) = @_; #the keyword to run
	
	#define return data structure
	
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
		return => '',
	);
    
	if($method eq "stop_remote_server"){
		my $output = '';
		if($self->{_enableStopSvr} == 0){
			$output = 'NOTE: remote server not configured to allow remote shutdowns. Your request has been ignored.';
		}else{
			$output = 'NOTE: remote server shutting/shut down.';
			my $thr = threads->create(\&doShutdown);
		}
		my %shutdown_result = (
			status => 'PASS',
			output => $output,
			error => '',
			traceback => '',
			return => '',
			);
		return \%shutdown_result;
	}
	#based on code snippet from
	#http://en.wikipedia.org/wiki/Reflection_(computer_programming)#Perl
	my $class = $self->{_lib};
	my $retval;
	
	#DEBUG
	print "method = ".$method."\n";
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
	$keyword_result{return} = $retval if defined($retval);
	
	return \%keyword_result;
}

#internal remote server methods
#based on code snippet from
#http://www.ibm.com/developerworks/webservices/library/ws-xpc1/#l3
#and suggestions from
#http://stackoverflow.com/questions/6086584/problems-with-perl-xml-rpc-in-combination-with-perl-reflection
sub start_server {
	my ($self) = @_;
	my $svr = Frontier::Daemon->new(
                  methods => {
                  get_keyword_names => sub { $self->get_keyword_names(@_) },
                  run_keyword => sub { $self->run_keyword($_[0], eval{@{$_[1]}}) },
                  },
                  LocalAddr => $self->{_addr},
                  LocalPort => $self->{_port},
                  );
	#return $svr; # Never returns, stop server 
	#w/ stop_remote_server keyword, or Ctrl+C, etc.
}
#RPC::XML version
#NOTE: Code here untested to work or not
#sub start_server {
#	my ($self) = @_;
#	$srv = RPC::XML::Server->new(host => $self->{_addr}, port => $self->{_port});

	# Several of these, most likely:
#	$srv->add_method({ name => 'get_keyword_names',
#                           code => sub { $self->get_keyword_names(@_) },
#                           signature => [ 'array' ] });
#	$srv->add_method({ name => 'run_keyword',
#                           code => sub { $self->run_keyword($_[0], eval{@{$_[1]}}) },
#                           signature => [ 'struct array' ] });
#	$srv->server_loop; # Never returns, stop server 
	#w/ stop_remote_server keyword, or Ctrl+C, etc.
#}

sub doShutdown {
	my $delay = 5; #let's arbitrarily set delay at 5 seconds
	print "Shutting down remote server/library, from Robot Framework/XML-RPC request, in ".$delay." seconds\n";
	sleep $delay;
	print "Remote server/library shut down at ". strftime("%d%b%Y-%H:%M:%S\t",localtime(time()))."\n\n";
	exit();
}

#ending script/module return value to append below
1;
