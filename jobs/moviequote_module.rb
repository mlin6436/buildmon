# -*- coding: utf-8 -*-
require 'htmlentities'
require 'open-uri'
require 'httparty'

module MovieQuote
  class Job
    def self.update ( timeOut )
      # N.B. This module assumes the actor is valid
      
      actor = File.readlines(ENV['HOME'] + "/.actorlist").sample.chomp or die "Unable to open file..."

      actor_split = actor.split(/ /)
      actor_triple_barrel = actor_split[0] + ' ' + actor_split[1] + actor_split[2] if actor_split.length == 3

      actor_permutations = Array.new

      if actor_triple_barrel 
        actor_permutations.push((actor_triple_barrel.dup.gsub! ' ', '_' || actor_triple_barrel.dup).downcase)
        actor_permutations.push((actor_triple_barrel.dup.gsub! ' ', '-' || actor_triple_barrel.dup).downcase)
      end

      actor_permutations.push((actor.dup.gsub! ' ', '_' || actor.dup).downcase)
      actor_permutations.push((actor.dup.gsub! ' ', '-' || actor.dup).downcase)

      for actor_permutation in actor_permutations
        page_url = "http://www.rottentomatoes.com/celebrity/#{actor_permutation}/biography/"
        uri = URI.parse page_url
        result = Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri.path) }

        break if result.code == "200"
      end

      abort "Actor is not valid" if result.code == "404"
      
      page_source = result.body
      page_source.gsub! "\n", ''
      page_source.gsub! "\r", ''
      page_source.gsub! "\t", ''
      page_source.gsub! "  ", ''
      page_results = page_source.scan /<ol>(.*?)<\/ol>.*?<a.*?>(.*?)<\/a>/

      results = Hash.new

      for result in page_results
        next if (result[0].scan(/class="line">(.*?)<\/span>/).length > 1)
   
        quote = /class="line">(.*?)<\/span>/.match(result[0])[1]
        quote.gsub! /[\(\[].*?[\)\]] /, '' || quote.dup

        next if quote.length > 80 # Removes naughty quotes
        next if /\*+/.match(quote) # Removes naughty quotes
        next if /fuck/.match(quote) # Removes naughty quotes
        
        begin 
          film  = HTMLEntities.new.decode(result[1]) 
          quote = "“" + HTMLEntities.new.decode(quote) + "”"
        rescue 
          next
        end

        results[film] = Array.new unless results[film]
        results[film].push quote
      end
      
      film = results.keys.sample

      return_result = Hash.new
      return_result[:film]      = film
      return_result[:quote]     = results[film].sample
      return_result[:actor]     = "- " + actor
      return_result[:imageUrl]  = getImageUrl actor
      return_result[:revealTime]  = timeOut

      send_event("moviequote", return_result)
    end

    def self.getImageUrl ( actor )
      url = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q='
      url += URI.encode actor

      uri = URI.parse url

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = false

      request  = Net::HTTP::Get.new uri.request_uri
      result   = MultiJson.load http.request(request).body , symbolize_keys: true 
      
      for image_item in result[:responseData][:results]
        image_aspect = Float(image_item[:tbHeight]) / Float(image_item[:tbWidth]);
        
        break if 1.2 < image_aspect && image_aspect < 1.5
      end

      return image_item[:unescapedUrl]
    end
  end
end
