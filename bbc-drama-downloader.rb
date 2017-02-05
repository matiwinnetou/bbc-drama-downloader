require 'rufus-scheduler'
require 'open-uri'
require 'simple-rss'
require 'logger'

$scheduler = Rufus::Scheduler.new
$bbc_drama_feed_url = 'http://www.bbc.co.uk/programmes/p02nrv5m/episodes/downloads.rss'
$save_dir = Dir.pwd

def create_logger
  log = Logger.new(STDOUT)
  log.level = Logger::INFO
  log.progname = "bbc-drama-downloader"

  log.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    if severity == "INFO" or severity == "WARN"
      "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
    else
      "[#{date_format}] #{severity} (#{progname}): #{msg}\n"
    end
  end

  log
end

$log = create_logger

def fetch_feed(save_dir, feed_url)
  $log.info("Fetching feed: #{feed_url}")

  rss = SimpleRSS.parse open(feed_url)
  items = rss.items
  items.each { |item| process_item(save_dir, item) }
end

def process_item(save_dir, item)
  title = item[:title]
  mp3_link = item[:media_content_url]
  title_under = title.tr(" ", "_")
  file_name = "#{title_under}.mp3"
  store_filename = "#{save_dir}/#{file_name}"

  store_file(mp3_link, store_filename)
end

def store_file(url, saveFilePath)
  if (File.file?(saveFilePath))
    $log.warn("File already exists: #{saveFilePath}")
    return
  end
  $log.info("Downloading: #{saveFilePath}")
  File.open(saveFilePath, "wb") do |saved_file|
    open(url, "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end
  $log.info("Downloaded: #{saveFilePath}")
end

$log.info("Starting up...")
$log.info("Will save podcasts to: #{$save_dir}")

if ARGV[0] == '-d'
  $log.info("Immediate download selected")
  fetch_feed($save_dir, $bbc_drama_feed_url)
  $log.info("Downloaded and exiting...")
  exit 0
end

# 5 mins after midnight - everyday
$scheduler.cron('0 * * * *') do |job|
  begin
    fetch_feed($save_dir, $bbc_drama_feed_url)
    $log.info("Next time will be around: #{job.next_time}")
    $log.info("Sleeping...")
  rescue => e
    $log.fatal("Unable to run job:")
    $log.fatal(e)
  end
end

$log.info("Scheduler join...")

$scheduler.join
