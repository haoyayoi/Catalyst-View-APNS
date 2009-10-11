package Catalyst::View::APNS;

use strict;
use warnings;
use base qw/ Catalyst::View /;
use AnyEvent::APNS;
use Carp;
our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/apns cv/);

sub new {
    my ( $class, $c, $arguments ) = @_;
    my $self => $class->next::method($c);
    
    my $cv = AnyEvent->condvar;
    $self->cv($cv);

    my $apns;
    if (my $args = $self->{apns}) {
        if (ref($args) eq 'HASH') {
            $self->{apns}->{sandbox} = 0
                unless $self->{apns}->{sandbox};
            $apns = AnyEvent::APNS->new(
                certificate => $self->{apns}->{certification},
                private_key => $self->{apns}->{private_key},
                sandbox     => $self->{apns}->{sandbox},
            );
        } else {
            croak "Invalid new specified, check pod for AnyEvent::APNS";
        }
    }
    $self->apns($apns);
    return $self;
}

sub process {
    my ( $self, $c ) = @_;
    croak "Unable to push notification, bad apns configuration"
        unless $self->apns;
    croak "Invalid payload specified, check pod for AnyEvent::APNS"
        unless (ref($c->{apns}->{payload}) eq 'HASH');
    $self->apns->connect;
    $self->apns->send( $c->{apns}->{device_token}, $c->{apns}->{payload} );
    $self->apns->handler->on_drain(
        sub {
            undef $_[0];
            $self->cv->send;
        }
    );
    $self->cv->recv;
}

1;
__END__

=head1 NAME

Catalyst::View::APNS - APNS View Class.

=head1 SYNOPSIS

# lib/MyApp/View/APNS.pm
package MyApp::View::APNS;
use base qw/Catalyst::View::APNS/;
1;

# Configure in lib/MyApp.pm
MyApp->config({
    apns => {
        certification => cert #require to specify
        private_key   => key  #require to specify
        sandbox       => 0|1  #optional
    }
});

sub hello : Local {
    my ( $self, $c ) = @_;
    $c->stash->{apns}->{device_token} = $device_token;
    $c->stash->{apns}->{payload} = $payload;
    $c->forward('MyApp::View::APNS');
}

Use the helper to create your View:
 
    myapp_create.pl view APNS APNS

=head1 DESCRIPTION

Catalyst::View::APNS is Catalyst view handler that Apple Push Notification Service.

=head1 AUTHOR

haoyayoi E<lt>st.hao.yayoi@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
