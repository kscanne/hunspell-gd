#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

# Both WORDLIST and FREQLIST should have words, bigrams, trigrams, etc.
if ($#ARGV != 2) {
	die "Usage: perl toadaptxt.pl xx WORDLIST FREQLIST";
}

# don't include more than this number of words/phrases in inclusion file
my $max = 100000;
my %dict;
open(DICT, "<:utf8", $ARGV[1]) or die "Could not open clean word list: $!";
while (<DICT>) {
	chomp;
	$dict{$_}++;
}
close DICT;

my $count = 0;
# don't include words with freq lower than cutoff (so 0 == no effect)
# it's set automatically in loop below...
my $cutoff = 0;
my %freq;
open(FREQ, "<:utf8", $ARGV[2]) or die "Could not open frequency list: $!";
while (<FREQ>) {
	chomp;
	(my $c, my $w) = /^ *([0-9]+) (.+)$/;
	next if ($w =~ /^[htn]-/); # handled by so-called "elision rules"
	next if ($w =~ /^.'[aeiouáéíóúAEIOUÁÉÍÓÚ]/);
	next if ($w =~ /[.]/);
	my $lowered = lcfirst($w);
	if (exists($dict{$lowered})) {
		$w = $lowered;
	}
	else {
		next unless exists($dict{$w});
	}
	if ($w =~ /\p{Ll}.*\p{Lu}/) {  # hÉireann -> héireann
		# tAcht -> tacht, but that's ok; idea is for end users to correct, as
		# lame as that is...
		$w = lc($w);
	}
	if (exists($freq{$w})) {
		$freq{$w} += $c;
	}
	else {
		$freq{$w} = $c;
		$count++;
		if ($count == $max) {
			print STDERR "Cutoff set to $c\n";
			$cutoff = $c;
		}
	}
}
close FREQ;

open(INCLUSION, ">:utf8", "$ARGV[0]_inclusion-utf8.txt") or die "Could not open inclusion file: $!";
$count = 0;
for my $k (sort keys %freq) {
	next if ($freq{$k} <= $cutoff);
	next if ($k =~ / /);
	last if ($count >= $max);
	print INCLUSION "$k\n";
	$count++;
}
close INCLUSION;

open(CORPUS, ">:utf8", "$ARGV[0]_corpus-utf8.txt") or die "Could not open corpus file: $!";
$count = 0;
for my $k (sort keys %freq) {
	next if ($freq{$k} <= $cutoff);
	last if ($count >= $max);
	my $num = $freq{$k};
	for (1..$num) {
		print CORPUS "$k ,\n";
	}
	$count++;
}
close CORPUS;

exit 0;
