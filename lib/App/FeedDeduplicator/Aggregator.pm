use v5.38;
use feature 'class';
no warnings 'experimental::class';

class App::FeedDeduplicator::Aggregator {
    use XML::Feed;
    use LWP::UserAgent;

    field $feeds :param;
    field $entries :reader;

    method fetch_all {
        my $ua = LWP::UserAgent->new(timeout => 10);
        my @all_entries;

        for my $url (@$feeds) {
            my $response = $ua->get($url);
            next unless $response->is_success;

            my $feed = XML::Feed->parse(\$response->decoded_content);
            next unless $feed;

            for my $entry ($feed->entries) {
                push @all_entries, $entry;
            }
        }

        $entries = \@all_entries;
    }
}
