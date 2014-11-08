package CopyThisEntry::CMS;

use strict;
use warnings;

sub _hdlr_copy_this_entry {
    my $app     = shift;
    my $blog_id = $app->param('blog_id');

    return $app->return_to_dashboard( permission => 1 )
        unless $app->can_do('create_post');
    return $app->errtrans('Invalid request') unless $blog_id;

    my $id = $app->param('id');
    return $app->errtrans('Invalid request') unless $id;

    my $entry = $app->model('entry')->load($id)
        or return $app->errtrans('Invalid request');

    my $perms = $app->permissions
        or return $app->errtrans('Invalid request');

    return $app->return_to_dashboard( permission => 1 )
        unless $perms->can_edit_entry( $entry, $app->user );

    return $app->redirect(
        $app->uri(
            'mode' => 'view',
            args   => {
                blog_id => $blog_id,
                origin  => $id,
                _type   => $entry->class,
            }
        )
    );

}

1;
