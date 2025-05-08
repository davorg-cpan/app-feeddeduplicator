use v5.38;
use feature 'class';
no warnings 'experimental::class';

class App::FeedDeduplicator::Publisher {
    use XML::Feed;
    use JSON::MaybeXS;

    field $entries :param;
    field $format  :param;

    method publish {
        my @sorted = sort {
            ($b->issued || $b->modified || $b->updated || $b->date || 0)
                <=> ($a->issued || $a->modified || $a->updated || $a->date || 0)
        } @$entries;

        if ($format eq 'json') {
            say encode_json([ map { {
                title => $_->title,
                link  => $_->link,
                summary => $_->summary,
                issued => $_->issued && $_->issued->iso8601,
            } } @sorted ]);
        } else {
            my $feed = XML::Feed->new($format);
            $feed->title("Deduplicated Feed");
            $feed->add_entry($_) for @sorted;
            say $feed->as_xml;
        }
    }
}
