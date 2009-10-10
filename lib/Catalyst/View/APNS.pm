package Catalyst::View::APNS;

use strict;
use warnings;
use base qw/ Catalyst::View /;
use Encode qw/encode decode/;
use APNS::APNS;
our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/apns/);

sub new {
    my ( $class, $c, $arguments ) = @_;
    my $self => $class->next::method($c);

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
