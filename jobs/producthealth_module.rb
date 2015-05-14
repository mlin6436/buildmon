require_relative './http_helper'

module ProductHealth
  class Product
    def self.updateUsing(configObject)
      config = configObject.config

      product_health_hash = {}
      product_health_hash[:colCount] = config[:col_count]
      product_health_hash[:job_css] = config[:job_css]

      product_health_components_hash = {}

      config[:products].each { |product|
        url = product[:url]
        # component_jobs = component[:jobs]
        status_hash = get_hash_from_json(HttpHelper.get_product(url))
        components = status_hash[:components]

        components.each do |component|
          type = component[:type]
          identifier = component[:identifier]
          working = component[:working]

          name = type + " " + identifier
          product_health_components_hash[name] = {name: name, status: working == true ? "green" : "red"}
        end



        # component_jobs.each do |job_name, name|
        #   ci_job = self.get_job(status_hash[:jobs], job_name)
        #
        #   unless ci_job.nil?
        #     # ci_root_domain = ci_root.match(/^http.*8080/)[0]
        #     # unless ci_job[:url].start_with?(ci_root_domain)
        #     #   puts ('WARNING: environment (' + ci_root_domain + ') is pointing to another for its config: ' + ci_job[:url])
        #     # end
        #
        #     job_health_components_hash[name] ||= {name: name, jobs: [], soft_name: name}
        #     if component[:add_branch_names]
        #       job_health_components_hash[name][:branch_name] = self.get_branch_name(ci_job)
        #     end
        #
        #     job_health_components_hash[name][:jobs] << ci_job[:name]
        #     self.set_status(job_health_components_hash[name], ci_job[:color])
        #   end
        # end
      }

      product_health_hash[:components] = product_health_components_hash.values

      send_event(config[:job_prefix] + 'producthealth', product_health_hash)
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

    def self.set_status(product_health_components_hash, colour)
      if colour == 'disabled'
        product_health_components_hash[:status] = "grey"
      elsif self.is_building(colour)
        product_health_components_hash[:status] = "blue job flashing"
      elsif colour == 'red'
        product_health_components_hash[:status] = "red"
      end
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
