package TestApp;

use strict;
use warnings;
use Catalyst;
our $VERSION = '0.01';

__PACKAGE__->config({
    name => 'TestApp',
    'View::APNS' => {
         apns => {
             certificate => "test",
             private_key => "key",
             sandbox     => 1,
         }
    },
});

__PACKAGE__->setup;

sub appname : Global {
    my ( $self, $c ) = @_;
    $c->stash->{payload} = {
        aps => {
            alert => "Test",
        },
    };
    $c->forward('TestApp::View::APNS');
}

sub push : Global {
    my ( $self, $c ) = @_;
    $c->stash->{payload} = {
        aps => {
            alert => "Test",
        },
    };
    $c->forward('TestApp::View::APNS');
}

1;
