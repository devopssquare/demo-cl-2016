#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::HTML::Content (tests => 1);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();
my $url = 'http://admin:admin@localhost:8080/';
# Associate the mechanize object with a URL
$mech->get($url);
# Test for the footer in the content of the URL
xpath_ok($mech->content, '/html/body/footer', 'Jenkins HTML contains footer');