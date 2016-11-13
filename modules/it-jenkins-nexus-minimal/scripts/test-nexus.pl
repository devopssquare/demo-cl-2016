#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use XML::LibXML;
use Test::More (tests => 1);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();

my $url= 'http://localhost:8081/nexus/content/groups/public/net/aschemann/demo/hello-world/maven-metadata.xml';
# Associate the mechanize object with a URL
$mech->get($url);

my $parser = XML::LibXML->new();
my $doc = $parser->parse_string($mech->content);

my @versions = $doc->findnodes("/metadata/versioning/versions");
ok ($#versions >= 0, "Found artifact versions ($#versions)");
