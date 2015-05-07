
require_relative './http_helper'

module JobHealth
  class Job
    def self.updateUsing(configObject)
      config = configObject.config

      jobs_health_hash = {}
      job_health_components_hash = {}
      jobs_health_hash[:colCount]   = config[:col_count]
      jobs_health_hash[:job_css]   = config[:job_css]

      config[:components].each { |component|
        ci_root = component[:ci_root]
        ci_version = component[:ci_version]
        component_jobs = component[:jobs]
        ci_view_hash = get_hash_from_json(HttpHelper.get(ci_root))

        component_jobs.each do |job_name, name|
          ci_job = self.get_job(ci_view_hash[:jobs], job_name)

          unless ci_job.nil?
            # ci_root_domain = ci_root.match(/^http.*8080/)[0]
            # unless ci_job[:url].start_with?(ci_root_domain)
            #   puts ('WARNING: environment (' + ci_root_domain + ') is pointing to another for its config: ' + ci_job[:url])
            # end

            job_health_components_hash[name] ||= {name: name, jobs: [], soft_name: name}
            if component[:add_branch_names]
              job_health_components_hash[name][:branch_name] = self.get_branch_name(ci_job)
            end

            job_health_components_hash[name][:jobs] << ci_job[:name]
            self.set_status(job_health_components_hash[name], ci_job[:color], ci_version)
          end
        end
      }

      jobs_health_hash[:components] = job_health_components_hash.values

#      p "sending jobs_health event: " + jobs_health_hash.to_s
      send_event(config[:job_prefix] + 'jobhealth', jobs_health_hash)
    end

    private
    def self.get_job(jobs_hash, job_name)
      jobs_hash.each do |job|
        if job[:name] == job_name
          return job
        end
      end
      p "WARNING! can not find job: " + job_name
    end

    def self.set_status(job_health_component, colour, ci_version)
      if colour == 'disabled'
        job_health_component[:status] = "grey"
      elsif self.is_building(colour)
        job_health_component[:status] = "blue job flashing"
      elsif colour == 'red'
        job_health_component[:status] = "red"
      elsif self.translate_ci_build_ok_colour(ci_version, colour) == 'green'
        job_health_component[:status] = "green"
      elsif self.translate_ci_build_ok_colour(ci_version, colour) == 'blue'
        job_health_component[:status] = "green"
      end
    end

    def self.translate_ci_build_ok_colour(ci_version, colour)
      if (ci_version == "1" && colour == "blue")
        return "green"
      end

      colour
    end

    def self.is_building (colour)
      (colour.include? "flash") || (colour.include? "anime")
    end

    def self.get_branch_name (ci_job)
      last_build_hash = get_hash_from_json(HttpHelper.get(ci_job[:url] + 'lastBuild/api/json'))

      # Git
      unless last_build_hash[:actions].nil?
        last_build_hash[:actions].each { |action|
          unless action[:lastBuiltRevision].nil? || action[:lastBuiltRevision][:branch].nil? || action[:lastBuiltRevision][:branch].size == 0
            return action[:lastBuiltRevision][:branch][0][:name]
          end
        }
      end

      # SVN
      if last_build_hash[:changeSet] && last_build_hash[:changeSet][:revisions]
        branch_name = last_build_hash[:changeSet][:revisions][0][:module]
        match = branch_name.match(/\/(trunk|branches).*/)
        return match ? match[0] : branch_name
      end

      # Triggered by upstreamProject
      unless last_build_hash[:actions].nil?
        last_build_hash[:actions].each { |action|
          unless action[:causes].nil? || action[:causes].size == 0 || action[:causes][0][:upstreamProject].nil?
            return 'triggered by: ' + action[:causes][0][:upstreamProject]
          end
        }
      end

      return 'NOT FOUND'
    end
  end
end
