package CopyThisEntry::Plugin;

use strict;
use warnings;
use CustomFields::App::CMS;

my $func;
sub init {
    {
        no strict 'refs';
        $func = \&CustomFields::App::CMS::populate_field_loop;
        *CustomFields::App::CMS::populate_field_loop = \&_populate_field_loop;
    };
}

sub _populate_field_loop {
    my $app = MT->instance;

    return
        if $app->param('origin') && !$app->param('id');
    return $func->(@_);
}

1;
