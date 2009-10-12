use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;
use Catalyst::Test 'TestApp';

plan tests => 1;

my $entrypoint = "http://localhost/appname";
{
    eval {
        my $response = request($entrypoint);
        is ($response->code, 500, "request error");
    };
    if ($@) {
        like($@, /Invalied/);
    }
}

1;
