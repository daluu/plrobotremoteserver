#!/usr/bin/env perl

#class
package ExampleLibrary;
use File::Find::Rule;
#use strict;
#use warnings;

#now implement Robot Framework keyword class methods below

sub count_items_in_directory{
	my ($self, $path) = @_;
	my $dirRules =  File::Find::Rule->new;
	# count sub-directories in directory
	$dirRules->directory;
	$dirRules->not( File::Find::Rule->new->name( qr/^\.+$/ ) );
	my @subdirs = $dirRules->in($path);
	# count files in directory
	my $fileRules =  File::Find::Rule->new;
	$fileRules->file;
	$fileRules->not( File::Find::Rule->new->name( qr/^\.+$/ ) );
	my @files = $fileRules->in($path);
	return scalar(@subdirs) + scalar(@files);
}

sub strings_should_be_equal{
	my ($self, $str1, $str2) = @_;
        print "Comparing '$str1' to '$str2'\n";
        if($str1 ne $str2){
		die ("Given strings are not equal");
	}
}

#ending script/module return value to append below
1;
