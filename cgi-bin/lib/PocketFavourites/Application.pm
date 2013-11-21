package PocketFavourites::Application;

use Carp;
use LWP::UserAgent;
use FormEncoder;
use ResponseParser;

sub new
{
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $self = bless {}, $class;
    
   my $opts = shift; 
   if ($opts) { #todo - refactor to remove conditional and the loop
        foreach my $key (%$opts) {
               $self->{$key} = $opts->{$key};
        }
   }

    return $self;
}

sub ua #a subclass of LWP::UserAgent
{
    my $self = shift;
    carp ("'ua' has not been set") unless $self->{ua}; #todo - refactor with a more elegant exception handler
    return $self->{ua};
}

sub config #a subclass of Config::IniFiles
{
    my $self = shift;
    carp ("'config' has not been set") unless $self->{config}; #todo - refactor with a more elegant exception handler
    return $self->{config};
}

sub env #environment: dev|live
{
    my $self = shift;
    carp ("'env' has not been set") unless $self->{env}; #todo - refactor with a more elegant exception handler
    return $self->{env};
}

sub api_uri #the pocket api uri (the bit before the v3)
{
    my $self = shift;
    my $val = $self->config->val($self->env, 'api_uri');
    carp ("'api_uri' has not been set in the config") unless $val;
    return $val;
}

sub consumer_key_web  #the consumer key assigned by pocket to this app
 {
    my $self = shift;
    my $val = $self->config->val($self->env, 'consumer_key_web');
    carp ("'consumer_key_web' has not been set in the config") unless $val;
    return $val;
}

sub redirect_uri {
    my $self = shift;
    my $val = $self->config->val($self->env, 'redirect_uri');
    carp ("'redirect_uri' has not been set in the config") unless $val;
    return $val;
}

sub request_token {
    my $self = shift;
    carp ("'request_token' has not been set. call fetch_request_token first") unless $self->{request_token}; #todo - refactor with a more elegant exception handler
    return $self->{request_token};
}

sub set_request_token {
    my $self = shift;
    my $request_token = shift;
    $self->{request_token} = $request_token;
    return 1;
}

sub access_token {
    my $self = shift;
    carp ("'access_token' has not been set. call authorize first") unless $self->{access_token}; #todo - refactor with a more elegant exception handler
    return $self->{access_token};
}

sub fetch_request_token {

    my $self = shift;

    my $state = '-'; #todo - pass something about the current user to the in here, an hashed id maybe?
    
    my $url = $self->api_uri . '/v3/oauth/request/';
    my $post_data = {
            'redirect_uri'=>$self->redirect_uri,
            'consumer_key'=>$self->consumer_key_web,
            'state' => $state
    };

    my $request = new HTTP::Request('POST' => $url);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content_encoding('UTF-8');
    $request->header('X-Accept' => 'application/json');
    $request->content(FormEncoder::urlencode($post_data));
    
    my $response = $self->ua->request($request);

    my $data = ResponseParser::parse($response);
    
    my $request_token = $data->{code}; #this is what we're really looking for out of the oauth response
    $self->{request_token} = $request_token;

    return 1; #success
         
}
    
sub oauth_auth_uri {
    my $self = shift;
    return $self->api_uri . '/auth/authorize?' . FormEncoder::urlencode({'request_token'=>$self->request_token, 'redirect_uri' => $self->redirect_uri});
} 

sub authorize {

    my $self = shift;
    
    my $url = $self->api_uri . '/v3/oauth/authorize';
    my $post_data = {
            'code'=>$self->request_token,
            'consumer_key'=>$self->consumer_key_web
        };
    
    my $request = new HTTP::Request('POST' => $url);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content_encoding('UTF-8');
    $request->header('X-Accept' => 'application/json');
    $request->content(FormEncoder::urlencode($post_data));
    
    my $response = $self->ua->request($request);
   
    my $data = ResponseParser::parse($response);

    my $request_token = $data->{access_token}; #this is what we're really looking for out of the oauth response
    my $username = $data->{username}; #this is a nice bonus
    $self->{access_token} = $access_token;
    $self->{username} = $username;

    return 1;
         
}
    
sub fetch_feed_data { #todo - refactor as an adapter - this request code is quite re-usable
    my $self = shift;
    my $since = time - (7*24*60*60); #last 7 days

    my $url = $self->api_uri . '/v3/get/';
    my $post_data = {
            'access_token'=>$self->access_token,
            'consumer_key'=>$self->consumer_key_web,
            'favourite'=>1,
            'sort'=>'newest',
           'since'=>$since
        };
    
    my $request = new HTTP::Request('POST' => $url);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content_encoding('UTF-8');
    $request->header('X-Accept' => 'application/json');
    $request->content(FormEncoder::urlencode($post_data));
    
    my $response = $self->ua->request($request);
    
    my $data = ResponseParser::parse($response);
    return $data;
}

1;