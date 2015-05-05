require_relative './http_helper'
require 'digest/md5'

module BuildHealth
  class Job
    def self.updateUsing ( configObject )
      config = configObject.config

      build_health = Hash.new
      broken_builds = Array.new
      
      config[:ci_components].each { |ci_component|
        ci_root = ci_component[:ci_root]
        includes_regex = ci_component[:includes_regex]
          
        build_hash = get_hash_from_json(HttpHelper.get(ci_root))

        ci_jobs = build_hash[:jobs] 
        ci_jobs.each do |component|
          if self.include_job?(component[:name], includes_regex) && (component[:color] == 'red' || component[:color] == 'yellow')

            job_json = HttpHelper.get(component[:url] + '/lastBuild/api/json')
            build_job_hash = get_hash_from_json job_json

            if build_job_hash[:culprits].length > 0
              full_name_string = build_job_hash[:culprits][0][:fullName]
              trigger_kind = build_job_hash[:changeSet][:kind]
              
              user_json = HttpHelper.get(build_job_hash[:culprits][0][:absoluteUrl] + '/api/json')
              user_hash = get_hash_from_json user_json
              
              blamee = get_blamee full_name_string, trigger_kind, user_hash

              component[:image_url] = "http://www.gravatar.com/avatar/#{blamee[:email_hash]}?s=200&d=" + config[:default_gravatar]
              component[:committer] = blamee[:name]
              component[:brokenAt]  = build_job_hash[:timestamp]
            else
              component[:image_url] = config[:default_gravatar]
              component[:committer] = ''
            end

            broken_builds.push component
          end
        end
      }

      build_health[:builds] = broken_builds.length > 0 ? broken_builds : config[:stable_build]

      send_event(config[:job_prefix] + 'build_health', build_health)
    end
    
    private
    def self.include_job? job_name, regex
      regex.nil? || regex.empty? || Regexp.new(regex).match(job_name)
    end

    def self.get_blamee name, kind, user_hash
      if kind.eql? "git"
        email = user_hash[:property][1][:address]
        if !user_hash[:description].nil?
          email = user_hash[:description]
        end
      end

      if kind.eql? "svn"
        split_name_string = /emailAddress=(.*?)[\/_]CN=(.*?)[_\/]/.match(name)
        email = split_name_string[1]
        name = split_name_string[2]
      end
      return Hash[:name => name, :email_hash => Digest::MD5.hexdigest(email)]
    end
  end
end

