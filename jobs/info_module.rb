require_relative './http_helper'

module Info
  class Job
    def self.updateUsing ( configObject )
      config = configObject.config

      url = config[:svn_base] + "/" + config[:component]
      result = `svn list #{url}/tags | grep -E \"#{config[:regex]}\" | sort -r | head -1`

      result = result.chomp
      result = result.sub('/', '')
      
      self.buildAndSendResult( 'latest_tag', config, result, nil )
    end

    def self.updateVersionUsing( configObject)
      config = configObject.config
      
      job_hash = get_hash_from_json(HttpHelper.get(config[:components][:version_url]))

      result = get_key(config[:components][:version_param], job_hash)

      self.buildAndSendResult( 'latest_version', config, result, nil )
    end

    def self.updateUsingCurl( configObject )
      config = configObject.config

      result = ''
      response = `curl #{config[:curl_url]} 2>/dev/null`
      if response
        result = Regexp.new(config[:curl_regex]).match(response)
        result = result[1]
      end

      font_size = config[:font_size] || "80px"
      if config[:scalable_font_size]
        font_size = (config[:scalable_font_size][:base] - (result.scan(/\d/).length * config[:scalable_font_size][:scale])).to_s + "px"
      end
      
      self.buildAndSendResult( "info", config, result, font_size )
    end

    def self.buildAndSendResult( job_type, config, info, font_size )
      result_hash = Hash.new
      
      result_hash[:info] = info
      result_hash[:fontSize] = font_size || "80px"
      
      result_hash[:title] = config[:title]
      result_hash[:color] = config[:color]
      result_hash[:moreinfo] = config[:more_info]
      result_hash[:fontColor] = config[:font_color] || "rgba(255,255,255,0.7)"

      send_event(config[:job_prefix] + job_type, result_hash)
    end
  end
end


