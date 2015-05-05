require_relative './http_helper'

module JobAlerter 
  class Job
    def self.updateUsing(configObject)
      config = configObject.config

      all_hash = Hash.new
      status_hash = Hash.new

      config[:components].each { |component|
        ci_root = component[:ci_root]
        ci_version = component[:ci_version]
        component_jobs = component[:jobs]
        ci_view_hash = get_hash_from_json(HttpHelper.get(ci_root))
        
        component_jobs.each  { |job_name|
          ci_job = self.get_job(ci_view_hash[:jobs], job_name)
          
          unless ci_job.nil?
            unless (ci_job[:color] == 'green') || (ci_version == "1" && ci_job[:color] == 'blue')
              unless status_hash[ci_job[:color]]
                status_hash[ci_job[:color]] = Array.new
              end
              
              status_hash[ci_job[:color]].push({
                                                 name: ci_job[:name],
                                                 soft_name: ci_job[:name]
                                               })
            end
          end
        }
      }

      all_hash[:statuses] = status_hash

#      p " sending jobs_alerter event: " + all_hash.to_s
      send_event(config[:job_prefix] + 'jobs_alerter', all_hash)
    end
    
    private
    def self.get_job(jobs_hash, job_name)
      jobs_hash.each do |job|
        if job[:name] == job_name
          return job
        end
      end
      p "WARNING! can not find job: " + job_name
      nil
    end
  end
end
