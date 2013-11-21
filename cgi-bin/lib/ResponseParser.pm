package ResponseParser;

use Carp;
use JSON;

sub parse {
    my $response = shift; #a HTTP::Response object containing JSON data
    
    unless ($response->is_success) {
        my $x_error_code = $response->header('X-Error-Code');
        my $x_error = $response->header('X-Error');
         carp ("Error $x_error_code: $x_error - " . $response->status_line);
    }
     
    my  $json_text = $response->content;
    my $data = JSON->new->utf8->decode($json_text); 
    return $data; 
}

1;
