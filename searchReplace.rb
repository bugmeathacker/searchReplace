# Downloads URL and performs search and replace, then saves as your_domain.com.html
# Expects 3 arguments: URL, search word, replacement word.  
require 'open-uri'
require 'open_uri_redirections'
require 'public_suffix'

# Set command line args.
$url = ARGV[0]
$search_word = ARGV[1]
$replace_word = ARGV[2]

$uri = URI($url)

# Test for shortened URL and build complete URL.
# For example: 
# google.com => http://www.google.com/
def url_formater
    if $uri.instance_of?(URI::Generic)
        $uri = URI::HTTP.build({:host => $uri.to_s}) 
    end
end

# Attempts downloading URL, displays returned error and exits if unsuccesful.
# Prevents redirect errors using open_uri_redirections gem which patches open_uri to allow https to http redirects
# https://github.com/open-uri-redirections/open_uri_redirections
def url_downloader
    puts "Downloading source of #{$url}..."
    begin
        source = URI.open($uri, :allow_redirections => :all).read
    rescue OpenURI::HTTPError => error
        response = error.io
        puts response.status
        exit
    end
    source
end

# Trims url to shortend domain form with public_suffix gem
# in order to make a valid and clean filename.
# https://github.com/weppos/publicsuffix-ruby
def file_name_formater
    host = URI.parse($uri.to_s).host
    host
end

# .scan method used to find and display search_word occurences in url source
def  word_search(source)
    word_occur = source.scan(/#{$search_word}/i).count
    puts "Found #{word_occur} occurences of \"#{$search_word}\""
end

# .gsub method used with regex to replace all occurences of search_word with replace_word insensitive to case and surounding characters
# If it throws a TypeError program exits. Most likely URL downloaded is not text.
def word_replace(source)
    begin
        new_source = source.gsub(/#{$search_word}/i, $replace_word)
    rescue TypeError => error
        puts error.message
        puts "Error URL not a text filetype."
        exit
    end
    new_source
end

# Save resulting source code to current folder with domain as file name.
def file_save(host, new_source)
    out_file = File.new("#{host}.html", "w")
    out_file.puts(new_source)
    out_file.close
end

def summary_info(host)
    puts "Replaced all occurences of \"#{$search_word}\" with \"#{$replace_word}\""
    puts "Saved a new file as #{host}.html"
end


url_formater

host = file_name_formater

source = url_downloader

new_source = word_search(source)

word_replace(source)

file_save(host, new_source)

summary_info(host)
