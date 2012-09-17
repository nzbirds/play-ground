require 'colorize'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'stringex'

content = File.read('birds.json')
json = JSON.parse(content)

birds = {}
json.each do |bird|
  bird_name = bird.keys[0]
  url = "http://en.wikipedia.org/w/index.php?search=#{URI.encode(bird_name)}"

  # Request the page and follow the redirect. 
  puts "Processing #{bird_name}".green
  puts " - requesting: #{url}"
  doc = Nokogiri::HTML(open(url))

  # Check whether we get automatically redirected to the
  # proper page by checking "#firstHeading .auto"
  canonical_name = doc.css('#firstHeading span').first.content
  if canonical_name == "Search results"
    puts " - Search page located"
    suggestion = doc.css('.mw-search-results li a').first
    canonical_name = suggestion['title']
    doc = Nokogiri::HTML(open("http://en.wikipedia.org#{suggestion['href']}"))
  end
  puts " - Canonical name: #{canonical_name}".blue

  # Now we've got the specific wiki entry, write down the 
  # content into its own file.
  slug = canonical_name.to_url
  puts " - Write file #{slug}.html"
  File.write("#{slug}.html", doc.css('#mw-content-text').first.inner_html)

  # Update into json file.
  birds[canonical_name] = bird[bird_name]
  birds[canonical_name]['slug'] = slug
end 

File.write('birds2.json', birds.to_json)
