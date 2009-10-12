package Catalyst::View::APNS;

use strict;
use AnyEvent::APNS;
use base qw( Catalyst::View );
use Data::Dumper;
use Carp;
use Catalyst::Exception;
our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(apns cv certification private_key sandbox));

sub new {
    my ( $class, $c, $arguments ) = @_;
    my $self = $class->next::method($c);

    my $cv = AnyEvent->condvar;
    $self->cv($cv);
    for my $field (keys(%$arguments)) {
        next unless $field;
        next if $field ne 'apns';
        my $subs = $arguments->{$field};
        for my $subfield (keys(%$subs)) {
            if ($self->can($subfield)) {
                $self->$subfield($subs->{$subfield});
            } else {
                $c->log->debug("Invalied parameter ".$subfield);
            }
        }
    }
    unless ($self->certification) {
        croak "Invalied certification";
    }
    unless ($self->private_key) {
        croak "Invalied private_key";
    }
    if ($self->sandbox ne 1) {
        $self->sandbox(0);
    }

    my $apns;
    eval {
        $apns = AnyEvent::APNS->new(
            certificate => $self->certification,
            private_key => $self->private_key,
            sandbox     => $self->sandbox,
        );
    };
    if ($@) {
        croak $@;
    }
    $self->apns($apns);
    return $self;
}

sub process {
    my ( $self, $c ) = @_;
    croak "Invalid new setting, please read pod at AnyEvent::APNS"
        unless $self->apns;
    $self->apns->connect;
    $self->apns->send( $c->stash->{device_token}, $c->stash->{payload} );
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
