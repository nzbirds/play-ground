require 'nokogiri'

# Load a href in the web page. 
doc = Nokogiri::HTML(open('http://www.nzbirds.com/birds/gallery.html'))
birds = doc.css('a').collect {|link| link.content}

# Sort everything into a json. 
bl = {:birds => birds}
File.open('birds.json', 'w') do |f|
  f.write(bl.to_json)
end

# Manually remove all the non-bird stuff. 
