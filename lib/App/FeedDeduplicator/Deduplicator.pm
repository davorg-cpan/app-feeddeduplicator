use v5.38;
use feature 'class';
no warnings 'experimental::class';

class App::FeedDeduplicator::Deduplicator {
    use HTML::TreeBuilder::XPath;
    use LWP::UserAgent;
    use URI;

    field $entries :param;
    field $deduplicated :reader;

    method deduplicate {
        my %seen;
        my @result;

        for my $entry (@$entries) {
            my $canonical = $self->find_canonical($entry);
            my $key = $canonical // $entry->title;

            next if $seen{$key}++;
            push @result, $entry;
        }

        $deduplicated = \@result;
    }

    method find_canonical ($entry) {
        my $link = $entry->link;
        return unless $link;

        my $ua = LWP::UserAgent->new(timeout => 5);
        my $response = $ua->get($link);
        return unless $response->is_success;

        my $tree = HTML::TreeBuilder::XPath->new_from_content($response->decoded_content);
        my $node = $tree->findnodes('//link[@rel="canonical"]')->[0];

        return $node ? URI->new($node->attr('href'))->as_string : undef;
    }
}
