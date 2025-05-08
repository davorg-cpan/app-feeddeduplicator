use v5.38;
use feature 'class';
no warnings 'experimental::class';

class App::FeedDeduplicator {
    use App::FeedDeduplicator::Aggregator;
    use App::FeedDeduplicator::Deduplicator;
    use App::FeedDeduplicator::Publisher;
    use JSON::MaybeXS;
    use File::Spec;
    use File::HomeDir;

    method run ($class: $config_file = undef) {
        $config_file //= $ENV{FEED_DEDUP_CONFIG}
            // File::Spec->catfile(File::HomeDir->my_home, '.feed-deduplicator', 'config.json');

        open my $fh, '<', $config_file or die "Can't read config file: $config_file\n";
        my $config = decode_json(do { local $/; <$fh> });

        my $aggregator = App::FeedDeduplicator::Aggregator->new(feeds => $config->{feeds});
        $aggregator->fetch_all;

        my $deduplicator = App::FeedDeduplicator::Deduplicator->new(entries => $aggregator->entries);
        $deduplicator->deduplicate;

        my $publisher = App::FeedDeduplicator::Publisher->new(
            entries => $deduplicator->deduplicated,
            format  => $config->{output_format} // 'atom'
        );
        $publisher->publish;
    }
}
