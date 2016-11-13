#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::HTML::Content (tests => 2);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();

# First test case
my $url1 = 'http://admin:admin@localhost:8080/job/helloworld-seed';
# Associate the mechanize object with a URL
$mech->get($url1);
# Test for the footer in the content of the URL
xpath_ok($mech->content, '/html/body/footer', 'Jenkins Job "helloworld-seed" HTML contains footer');

my $url2 = 'http://admin:admin@localhost:8080/job/helloworld-install';
# Associate the mechanize object with a URL
$mech->get($url2);
# Test for the footer in the content of the URL
xpath_ok($mech->content, '/html/body/footer', 'Jenkins Job "helloworld-install" HTML contains footer');