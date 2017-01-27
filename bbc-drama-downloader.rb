require 'rufus-scheduler'
require 'open-uri'
require 'simple-rss'

scheduler = Rufus::Scheduler.new
bbc_drama_feed_url = 'http://www.bbc.co.uk/programmes/p02nrv5m/episodes/downloads.rss'
save_dir = ARGV[0]

def fetch_feed(save_dir, feed_url)
  puts("Fetching feed: " + feed_url)

  rss = SimpleRSS.parse open(feed_url)
  firstItem = rss.items[0]
  title = firstItem[:title]
  mp3_link = firstItem[:media_content_url]
  title_under = title.tr(" ", "_")
  file_name = "#{title_under}.mp3"
  store_filename = "#{save_dir}/#{file_name}"

  store_file(mp3_link, store_filename)
end

def store_file(url, saveFilePath)
  puts("Downloading: " + saveFilePath)
  File.open(saveFilePath, "wb") do |saved_file|
    # the following "open" is provided by open-uri
    open(url, "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end
  puts("Downloaded: " + saveFilePath)
end

if ARGV[1] == '-d'
  fetch_feed(save_dir, bbc_drama_feed_url)
  exit 0
end

# every friday at noon
scheduler.cron('0 0 * * FRI') do
  fetch_feed(save_dir, bbc_drama_feed_url)
end

scheduler.join