#!/usr/bin/perl -w

use strict;
use lib 'lib';
use Config::IniFiles;
use LWP::UserAgent;
use CGI;
use PocketFavourites::WebApplication;

my $env = 'dev'; #todo - refactor to use constant (could also be 'live')
my $config = new Config::IniFiles (-file => 'config.ini');
my $ua = new LWP::UserAgent;
$ua->env_proxy;
my $cgi = new CGI;

my $webapp = new PocketFavourites::WebApplication( {config => $config, ua => $ua, env => $env, cgi => $cgi} ); #mmm - dependancy injection
$webapp->run;
