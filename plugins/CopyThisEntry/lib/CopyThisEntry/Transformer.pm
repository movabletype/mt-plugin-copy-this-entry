package CopyThisEntry::Transformer;

use strict;
use warnings;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component('CopyThisEntry');

    # Do nothing for new entry.
    return if !$app->param('id') && !$app->param('origin');
    # If this request has origin parameter, remove ID from param;
    if ( $app->param('origin') ) {
        my $orig_id     = $app->param('origin');
        my $entry_class = $app->model('entry');
        if ( my $origin = $entry_class->load($orig_id) ) {

            # Original entry found
            if ( $app->user->permissions( $origin->blog_id )
                ->can_edit_entry( $origin, $app->user ) )
            {
                # Copy a data from original entry exclude some fields.
                my $cols = $entry_class->column_names;
                for my $col (@$cols) {
                    next
                        if $col eq 'created_on'
                        || $col eq 'created_by'
                        || $col eq 'modified_on'
                        || $col eq 'modified_by'
                        || $col eq 'authored_on'
                        || $col eq 'author_id'
                        || $col eq 'unpublished_on'
                        || $col eq 'pinged_urls'
                        || $col eq 'tangent_cache'
                        || $col eq 'template_id'
                        || $col eq 'class'
                        || $col eq 'meta'
                        || $col eq 'comment_count'
                        || $col eq 'ping_count'
                        || $col eq 'current_revision'
                        || $col eq 'id'
                        || $col eq 'atom_id'
                        || $col eq 'basename';

                    $param->{$col} = $origin->$col;
                }

                # Change status
                $param->{new_object} = 1;
                $param->{status}     = MT::Entry::HOLD();
                $param->{title}
                    = $plugin->translate( 'Copy of [_1]', $param->{title} );
                delete $param->{"status_publish"};
                delete $param->{"status_review"};
                delete $param->{"status_spam"};
                delete $param->{"status_future"};
                delete $param->{"status_unpublish"};
                $param->{"status_draft"} = 1;

                # Load Categories
                my $cats = $origin->__load_category_data;
                if ( @$cats ) {
                    my @cats;
                    my $primary_cat = $origin->category->id;
                    my $categories = $origin->categories;
                    my @cat_ids;
                    @cat_ids = map { $_->id }
                        grep { $_->id != $primary_cat } @$categories;
                    unshift @cat_ids, $primary_cat;
                    $param->{selected_category_loop} = \@cat_ids;
                }

                # Load CustomFields Data
                require CustomFields::App::CMS;
                $app->param( 'id', $orig_id );
                CustomFields::App::CMS::populate_field_loop( $cb, $app,
                    $param, $tmpl );
                $app->param( 'id', undef );

                # Load Tags
                my $tag_delim = chr( $app->user->entry_prefs->{tag_delim} );
                require MT::Tag;
                my $tags = MT::Tag->join( $tag_delim, $origin->tags );
                $param->{tags} = $tags;

                #TODO: Will support assets?
            }
        }

        # Copied entry does not need CopyThisEntry widget. Finish.
        return;
    }

    # Make a new widget
    my $widget = $tmpl->createElement(
        'app:widget',
        {   id    => 'copy-this-entry-widget',
            label => $plugin->translate('Copy This Entry'),
        }
    );

    $widget->appendChild(
        $tmpl->createTextNode(
            '<div style="margin-left: auto; margin-right: auto;"><button type="button" id="copy-this-entry" name="copy-this-entry" class="action button btn btn-default" style="width: 100%;">'
                . $plugin->translate('Copy This Entry')
                . '</button></div>'
        )
    );

    # Insert new widget
    $tmpl->insertBefore( $widget,
        $tmpl->getElementById('entry-status-widget') );

    # Support Script
    $param->{jq_js_include} ||= '';
    $param->{jq_js_include} .= <<SCRIPT;
    jQuery('#copy-this-entry').click(function() {
        app.clearDirty();
        jQuery('[name=entry_form] > [name=__mode]').val('copy_this_entry');
        jQuery('[name=entry_form]').submit();
    });
SCRIPT

}

1;
