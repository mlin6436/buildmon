require 'httparty'
require 'net/https'
require 'uri'

module Versions
  class Job
    def self.updateUsing( configObject )
      config = configObject.config

      version_array = Array.new

      config[:components].each do |component|

        version = "N/A"

        if component[:version_url]
          response = get_ssl component[:version_url]

          unless response.is_a? Hash
            response = get_hash_from_json response
          end
          
          version = get_key(component[:version_param], response)
        end

        if component[:curl_url]
          response = `curl #{component[:curl_url]} 2>/dev/null`
          if response
            version = Regexp.new(component[:curl_regexp]).match(response)
            version = version[1]
          end
        end
        
        rpm_warning = false
        last_successful_build = ''
        last_build = ''
        
        if component[:rpm_url]
          response = `curl -k --cert #{ENV['HOME']}/.subversion/svn.pem '#{component[:rpm_url]}' 2>/dev/null`
          if response
            rpm_version_array = response.scan(/#{component[:rpm_regexp]}/)
            rpm_warning = (!rpm_version_array.include? [version.to_s])
          end
        end
        
        if component[:hudson]
          job_hash = get_hash_from_json get_ssl(component[:hudson])
          last_successful_build = job_hash[:lastSuccessfulBuild][:number]
          last_build = job_hash[:lastBuild][:number]
        end

        version_array.push({
                             :name => component[:name],
                             :version => version,
                             :lastSuccessfulBuild => last_successful_build,
                             :lastBuild => last_build,
                             :rpmWarning => rpm_warning
                           })
      end

      result_hash = Hash.new
      result_hash = {
        :title => config[:environment],
        :color => config[:color],
        :fontSize => config[:font_size],
        :colCount => config[:colCount] || 1,
        :components => version_array
      }

      send_event(config[:job_prefix] + "versions", result_hash)
    end      
  end
end
