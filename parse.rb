#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'json'

## Input Params
LOCALE   = 'nl'
BASE_URL = "https://#{LOCALE}.airbnb.com"
SEARCH   = 'amsterdam'



## Airbnb parser
index_filename = './pages/index.html'
unless File.exists?("#{index_filename}")
  system ("wget -O #{index_filename} #{BASE_URL}/s/#{SEARCH}")
end

index_doc = Nokogiri::HTML(open("#{index_filename}"))

links_count = index_doc.css('.results-footer .list-unstyled li').count
pages_count = index_doc.css(".results-footer .list-unstyled li:eq(#{links_count-1})").text.to_i

puts "Total pages: #{pages_count}"




cur_page = 1
room_count = 0
all_rooms = []

page_doc = index_doc

begin


  if cur_page > 1

    puts "Get page: #{cur_page}"
    page_filename = "./pages/page#{cur_page}.html"

    unless File.exists?(page_filename)
      system("wget -O #{page_filename} #{BASE_URL}/s/#{SEARCH}")
    end

    page_doc = Nokogiri::HTML(open(page_filename))
  end

  page_doc.css('.listings-container .listing').each do |room_dom|
    data = {
      lat:     room_dom['data-lat'],
      lng:     room_dom['data-lng'],
      name:    room_dom['data-name'],
      price:   room_dom['data-price'],
      user_id: room_dom['data-user'],
      room_id: room_dom['data-id'],
      images: [],
      description: page_doc.css('meta[name="description"]').first['content']
    }

    puts "Get room: #{data[:room_id]}"
    room_filename = "./rooms/room#{data[:room_id]}.html"

    unless File.exists?(room_filename)
      system("wget -O #{room_filename} #{BASE_URL}/rooms/#{data[:room_id]}")
    end
    room_doc = Nokogiri::HTML(open(room_filename))

    user_dom = room_doc.css("[alt='shared.user_profile_image']").first

    data.merge! ({
      user_name:  user_dom['title'],
      user_img:   user_dom['src'].gsub('?aki_policy=profile_x_medium', '')
    })


    json_filename = "./json/room#{data[:room_id]}.json"
    unless File.exists?(json_filename)
      File.write(json_filename, room_doc.css(".___iso-state___p3hero_and_slideshowbundlejs").first['data-state'])
    end

    json_doc = JSON.parse(File.read(json_filename))
    json_doc['heroProps']['photos'].each do |img_json|
      data[:images] << img_json['picture'].gsub('?aki_policy=large', '')
    end

    puts data
    all_rooms << data

    room_count += 1
  end

  cur_page += 1

end while cur_page <= pages_count

puts "Total room count: #{room_count}"

File.write("output/#{LOCALE}_#{SEARCH}_data.json", all_rooms.to_json)
