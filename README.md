# bbc-drama-downloader

This is a little helper that I wrote that helps me to download BBC Drama of the week.
Unfortunately BBC decided to delete episodes after 2 weeks
and I tend to forget on certain weeks to download it. I usually come back to them and listen to them later.

## Usage
- ruby bbc-drama-downloader.rb /home/mati <download_directory> (refresh 5 mins after midnight everynight)
- ruby bbc-drama-downloader.rb /home/mati <download_directory> -D (download only)

## Bundler
- yaourt -S ruby-bundler
- bundle install --path vendor/bundle
- bundle exec ruby bbc-drama-downloader.rb