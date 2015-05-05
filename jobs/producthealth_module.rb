require_relative './http_helper'

module ProductHealth
  class Product
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
        ci_view_hash = get_hash_from_json(HttpHelper.getProduct(ci_root))

        component_jobs.each do |job_name, name|
          ci_job = ci_view_hash[:type]

          unless ci_job.nil?
            # ci_root_domain = ci_root.match(/^http.*8080/)[0]
            # unless ci_job[:url].start_with?(ci_root_domain)
            #   puts ('WARNING: environment (' + ci_root_domain + ') is pointing to another for its config: ' + ci_job[:url])
            # end

            job_health_components_hash[name] ||= {name: name, jobs: [], soft_name: name}

            job_health_components_hash[name][:jobs] << ci_job[:type]
            self.set_status(job_health_components_hash[name], ci_job[:working], ci_version)
          end
        end
      }

      jobs_health_hash[:components] = job_health_components_hash.values

#      p "sending jobs_health event: " + jobs_health_hash.to_s
      send_event(config[:job_prefix] + 'products_health', jobs_health_hash)
    end

    private
    def self.set_status(job_health_component, status, ci_version)
      if status == 'true'
        job_health_component[:status] = "green"
      else
        job_health_component[:status] = "red"
      end
    end
  end
end
