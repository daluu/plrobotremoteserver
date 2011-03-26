#!/usr/bin/env perl

# This is an example test library for RobotFramework.org test framework,
# for use with Perl remote server implementation. It is to be loaded
# into remote server at runtime via code/module/class/method reflection.

package ExampleLibrary;
use File::Find::Rule;
#use strict;
#use warnings;

#now implement keyword class methods below

sub count_items_in_directory{
	my ($path) = @_;
	# count sub-directories in directory
	my @subdirs = File::Find::Rule->directory->in($path);
	# count files in directory
	my @files = File::Find::Rule->file->in($path);
	# return total of files + dirs
	return scalar(@subdirs) + scalar(@files);
}

sub strings_should_be_equal{
	my ($str1, $str2) = @_;
        print "Comparing '$str1' to '$str2'";
        if($str1 ne $str2){
		die ("Given strings are not equal");
	}#else equal = PASS
}

#ending script/module return value to append below
1;
