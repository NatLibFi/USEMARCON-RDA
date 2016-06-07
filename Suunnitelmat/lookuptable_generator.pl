#!/bin/perl -w
#
# This script generates USEMARCON Look Up Tables (*.tbl format) from Excel spreadsheets.
#
# Version: 1.0
# Created:
# 17.10.2014
# Updated:
# 30.3.2015
# 
# Copyright (c) 2014 The National Library Of Finland
# Author: Tuomo Virolainen (tuomo.virolainen@helsinki.fi)
#
# This program is free software; you can redistribute it and/or modify it under the terms of either: 
# a) the GNU General Public License as published by the Free Software Foundation; 
# either version 1 (https://www.gnu.org/licenses/old-licenses/gpl-1.0.txt), or (at your option) any later version http://www.fsf.org/licenses/licenses.html#GNUGPL), or 
# b) the "Artistic License" (http://dev.perl.org/licenses/artistic.html).

use strict;
use utf8;
use Spreadsheet::Read;
binmode(STDOUT, ':utf8');
my $timestamp = "File generated: ". localtime . "\n\n";

#########################################################################
# Fill in required specifications here.
my $inputfile = ReadData ("RDA-konversiosuunnitelmat.xlsx") || die $!;
my $outputfile = "336b2.tbl"; # An example
my $preamble = "Tekijanfunktiot.tbl -- Tekijän funktiotermien lyhenteiden avaus"; # An example
my $default_value = "COPY"; # COPY copies input value to output as is, if value is not found in Look Up Table

my $sheet = "4";
my $inputvalue_firstcell = "A5";
my $inputvalue_lastcell = "A60";
my $outputvalue_firstcell = "G5";
my $outputvalue_lastcell = "G60";

#########################################################################

$preamble .= "\n";
my %valuepairs;
(my $firstrow = $inputvalue_firstcell) =~ s/\D+//;
(my $lastrow = $inputvalue_lastcell) =~ s/\D+//;
(my $inputcolumn = $inputvalue_firstcell) =~ s/\d+//;
(my $outputcolumn = $outputvalue_firstcell) =~ s/\d+//;
my $inputcell;
my $outputcell;
my $inputcell_content;
my $outputcell_content;

open (OUTPUT, '>:utf8', $outputfile) || die $!;

# Read input and output values as key-value-pairs into a hash

for (my $row = $firstrow; $row <= $lastrow; $row++) 
{
	$inputcell = ($inputcolumn . $row);
	$outputcell = ($outputcolumn . $row);
	$inputcell_content = $inputfile->[$sheet]{$inputcell};
	$outputcell_content = $inputfile->[$sheet]{$outputcell};
	# Skip rows where either cell is empty.
	if (!defined ($inputcell_content) || !defined ($outputcell_content)) 
	{
		next;
	} 	
	else
	{
		# Avoid splitting composed characters in two
		utf8::decode($inputcell_content);
		utf8::decode($outputcell_content);
		$valuepairs{$inputcell_content} = $outputcell_content;
	}
}

# Generate the output file

print OUTPUT ($preamble . $timestamp);

for (sort keys %valuepairs)
{
	print OUTPUT &parse_data($_) . "\t| ";
	print OUTPUT &parse_data($valuepairs{$_}) . "\n";
}

print OUTPUT "#DEFAULT\t| " . $default_value;

close (OUTPUT);
my $items = keys %valuepairs;
print "Done, $items value pairs written into $outputfile.\n";

# This subroutine parses data into the required format: an extra whitespace is added between characters, 
# whitespaces and non-latin characters are replaced by their hexadecimal counterparts.

sub parse_data
{
	my $index;
	my $parsed_data;
	my $length = length($_[0]);
	for ($index = 0; $index < $length; $index++) 
	{
		if ( substr($_[0], $index, 1) =~ ' ' ) 
		{
			$parsed_data .= "0x20" . " ";
	 	} 
		elsif ( substr($_[0], $index, 1 ) =~ 'ä' ) 
		{
	 		$parsed_data .= "0xc3 0xa4" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'Ä' ) 
		{
	 		$parsed_data .= "0xc3 0x84" . " ";
	 	}
		elsif ( substr($_[0], $index, 1 ) =~ 'ö' ) 
		{
	 		$parsed_data .= "0xc3 0xb6" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'Ö' ) 
		{
	 		$parsed_data .= "0xc3 0x96" . " ";
	 	} 
		elsif ( substr($_[0], $index, 1 ) =~ 'å' ) 
		{
	 		$parsed_data .= "0xc3 0xa5" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'Å' ) 
		{
	 		$parsed_data .= "0xc3 0x85" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'é' ) 
		{
	 		$parsed_data .= "0xc3 0xa9" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'Æ' ) 
		{
	 		$parsed_data .= "0xc3 0x86" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'æ' ) 
		{
	 		$parsed_data .= "0xc3 0xa6" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'ø' ) 
		{
	 		$parsed_data .= "0xc3 0xb8" . " ";
	 	}
	 	elsif ( substr($_[0], $index, 1 ) =~ 'Ø' ) 
		{
	 		$parsed_data .= "0xc3 0x98" . " ";
	 	} 
		else 
		{	
			$parsed_data .= substr($_[0], $index, 1) . " ";
	 	}
	}
	return $parsed_data;
}
