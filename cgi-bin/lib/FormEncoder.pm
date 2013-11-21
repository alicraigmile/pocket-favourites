package FormEncoder;

use Encode;

=head2 encode - Encode a hashref of post data form variables as a x-www-form-urlencoded sring

  $content = FormEncoder::urlencode({'thing1' => 'value1', 'thing2' => 'value2'});
  
=cut

sub urlencode {
    my $fields = shift;
    my $content = '';
    foreach my $k (keys %$fields) {
        $content.="&" if($content ne "");
        my $c=$fields->{$k};
        if(not ref $c) {
            $c=Encode::decode_utf8($c) unless Encode::is_utf8($c);
            $c=Encode::encode("cp1251", $c, Encode::FB_HTMLCREF);
            $c=URI::Escape::uri_escape($c);
        }
        elsif(ref $c eq "URI::URL") {
            $c=$c->canonical();
            $c=URI::Escape::uri_escape($c);
        }
        $content.="$k=$c";
    }

    return $content;
}

1;