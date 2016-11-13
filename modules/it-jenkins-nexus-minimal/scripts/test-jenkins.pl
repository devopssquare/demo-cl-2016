#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::HTML::Content (tests => 2);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();

# First test case
my $url1 = 'http://admin:admin@localhost:8080/job/helloworld-deploy-seed';
# Associate the mechanize object with a URL
$mech->get($url1);
# Test for the footer in the content of the URL
xpath_ok($mech->content, '/html/body/footer', 'Jenkins Job "helloworld-deploy-seed" HTML contains footer');

my $url2 = 'http://admin:admin@localhost:8080/job/helloworld-deploy';
# Associate the mechanize object with a URL
$mech->get($url2);
# Test for the footer in the content of the URL
xpath_ok($mech->content, '/html/body/footer', 'Jenkins Job "helloworld-deploy" HTML contains footer');
