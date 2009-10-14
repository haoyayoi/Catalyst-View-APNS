package TestApp;

use strict;
use warnings;
use Catalyst;
our $VERSION = '0.01';
use FindBin;

__PACKAGE__->config({
    name => 'TestApp',
    'View::APNS' => {
         apns => {
             certification => "/cert.pem",
             private_key   => "/key.pem",
         }
    },
});

__PACKAGE__->setup;

sub appname : Global {
    my ( $self, $c ) = @_;
    $c->stash->{device_token} = 'd'x32;
    $c->stash->{alert} = "Test";
    $c->stash->{badge} = 5;
    $c->forward('TestApp::View::APNS');
}

sub push : Global {
    my ( $self, $c ) = @_;
    $c->stash->{device_token} = 'd'x32;
    $c->stash->{alert} = "Test";
    $c->stash->{badge} = 5;
    $c->forward('TestApp::View::APNS');
}

1;
