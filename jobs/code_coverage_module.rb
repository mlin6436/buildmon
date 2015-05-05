require 'nokogiri'

module CodeCoverage
  class Job
    def self.updateUsing (configObject)
      config = configObject.config
      report = Nokogiri::HTML(open(config[:cobertura_coverage_report_url]))
      code_coverage = (report.xpath("//coverage").attr("line-rate").value.to_f.round(2) * 100)
      send_event(config[:job_prefix] + 'code_coverage', { value: code_coverage, background_color: config[:background_color] } )
    end
  end
end
