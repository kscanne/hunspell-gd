#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my %affhash;

while (<STDIN>) {
	chomp;
	if (/\//) {
		(my $word, my $affixes) = m/^([^\/]+)\/(.+)$/;
		if (exists($affhash{$word})) {
			my $prev = $affhash{$word};
			while ($affixes =~ m/(.)/g) {
				my $oneflag = $1;
				unless ($prev =~ /$oneflag/) {
					$affhash{$word} .= $oneflag;
				}
			}
		}
		else {
			$affhash{$word} = $affixes;
		}
	}
	else {
		if (!exists($affhash{$_})) {
			$affhash{$_} = '';
		}
	}
}

foreach my $w (keys %affhash) {
	my $as = $affhash{$w};
	if ($as eq '') {
		print "$w\n";
	}
	else {
		print "$w/";
		my @affixlist = split(//,$as);
		foreach my $flag (sort @affixlist) {
			print $flag;
		}
		print "\n";
	}
}

exit 0;
