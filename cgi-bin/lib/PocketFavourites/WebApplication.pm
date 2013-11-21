package PocketFavourites::WebApplication;

use strict;
use PocketFavourites::Application;
use CGI::Session;
use HTML::Template;

use parent 'PocketFavourites::Application';

sub cgi # a subclass of CGI
{
    my $self = shift;
    carp ("'cgi' has not been set") unless $self->{cgi}; #todo - refactor with a more elegant exception handler
    return $self->{cgi};
}

sub run
{
	my $self = shift;
	
	#start or continue a session
	my $sid = $self->cgi->cookie('CGISESSID') || $self->cgi->param('CGISESSID') || undef;
	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
	
	#retreive the pocket request token from the current session
	my $request_token = $session->param("request_token");
	if ($request_token) {
	    $self->set_request_token($request_token);
	} else {
	    $self->fetch_request_token();
	    $request_token = $self->request_token; 
	    $session->param("request_token",  $request_token); #save request_token for next time
	    
	    my $t = new HTML::Template(filename => 'templates/authentication_required.tmpl');
	    $t->param('oauth_auth_uri' => $self->oauth_auth_uri);
	    print $self->cgi->header('text/html; charset=UTF8');
	    print $t->output;
	    return 1;
	}
	
	#retreive the pocket access token from the current session
	my $access_token = $session->param("access_token");
	my $username = $session->param("username");
	if ($access_token) {
	    $self->set_request_token($access_token);
	    $self->set_request_token($username);
	} else { #or go and fetch a new one - assumes the user has logged into pocket, and we've been redirected back here
	    $self->authorise();
	    $session->param("access_token",  $self->access_token); #save access_token and username for next time
	    $session->param("username",  $self->username );
	}
	
	#finally, we have access request_token and access_token, proceed to to work
	my $feed_data = $self->fetch_feed_data();
	my $list = $feed_data->{list}; #todo - call a factory method to return a model 
	my $template_filename = scalar @$list?  'templates/top_articles.tmpl' :  'templates/no_articles.tmpl';
	
	my $t = new HTML::Template(filename => $template_filename);
	$t->param('username' => $self->username);
	$t->param('list' => $feed_data->{list});
	print $self->cgi->header('text/html; charset=UTF8');
	print $t->output;
	return 1;
}

1;
