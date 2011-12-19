#!/usr/bin/perl
package main;
use strict;
use warnings;
use blib;

use POE::Attributes qw(wire_current_session wire_new_session);
use base qw(POE::Attributes);
use POE;
use POE::Session;
use POE::Kernel;
use Log::Fu;

my $counter = 0;

sub say_alias : Event
{
    my ($alias_name,$do_stop) = @_[ARG0,ARG1];
    log_infof("I was passed '%s'", $alias_name);
    if(!$do_stop) {
        $_[KERNEL]->post($alias_name, say_alias => $alias_name, 1);
    }
}

sub my_event :Event(foo_event, bar_event)
{
    log_warnf("I'm called as %s.", $_[STATE]);
}


sub handler:Catcher
{
    log_errf("Got exception from %s: %s",
             $_[ARG1]->{event}, $_[ARG1]->{error_str});
    $_[KERNEL]->sig_handled();
    $counter = 0;
}

sub reaper :Reaper
{
    log_errf("Reaped: PID=%d, STATUS=%d", $_[ARG1], $_[ARG2]<<8);
    $_[KERNEL]->sig_handled();
}

sub tick :Recurring(Interval => 2)
{
    log_info("Tick");
    $_[KERNEL]->yield('do_fork');
}

sub tock :Recurring(Interval => 1)
{
    log_info("Tock");
    die "This should throw an exception" if $counter++ > 2;
}

sub do_fork :Event
{
    return unless (fork() == 0);
    POE::Kernel->stop();
    log_info("I'm child $$");
    exit(0);
}


#Handle OS Signals
sub got_sig :SigHandler(INT,QUIT,STOP,TSTP)
{
    my $sig = $_[ARG0];
    log_errf("We get signal! %s", $sig);
    if($sig ne 'QUIT') {
        log_info("Not quitting. Send me a QUIT (^\\) to really quit");
        $_[KERNEL]->sig_handled();
    }
}

#Stolen from POE::Session's manpage
sub handle_default :Event(_default) {
    my ($event, $args) = @_[ARG0, ARG1];
    print(
      "Session ", $_[SESSION]->ID,
      " caught unhandled event $event with (@$args).\n"
    );
}

sub got_read :Event {
    
}

sub got_write :Event {
    
}

sub hello :Start
{
    log_info("Beginning");
    $_[KERNEL]->post($_[SESSION], $_, "Hi")
        for (qw(foo_event bar_event));
    $_[KERNEL]->yield(say_alias => "session alias", 0);
    $_[KERNEL]->yield('do_fork');
    $_[KERNEL]->yield('nonexistent');
    
    my $rfd : SelectRead(got_read);
    my $wfd : SelectWrite(got_write);
}

sub byebye :Stop
{
    log_warnf("We're stopping");
}


wire_new_session("session alias");
POE::Kernel->run();
