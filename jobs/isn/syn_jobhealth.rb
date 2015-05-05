require_relative '../jobhealth_module'
require_relative '../configuration_helper'

syn_config = Helpers::ConfigHelper.new({
    job_prefix: "syn_",
    col_count: 2,
    job_css: "medium_font",
    components: [
    {
      ci_root: "https://jenkins.bbc.co.uk/api/json/",
      jobs: {
        "bbc-search-adaptor" => "bbc-search-adaptor",
        "bbc-search-adaptor-cucumber" => "bbc-search-adaptor-cucumber",
        "business-data-api" => "business-data-api",
        "business-data-api-cucumber" => "business-data-api-cucumber",
        "business-data-config-api" => "business-data-config-api",
        "business-data-config-api-cucumber" => "business-data-config-api-cucumber",
        "business-data-cucumber" => "business-data-cucumber",
        "business-data-cucumber-smoke" => "business-data-cucumber-smoke",
        "business-data-fetchers" => "business-data-fetchers",
        "business-data-fetchers-cucumber" => "business-data-fetchers-cucumber",
        "business-data-initiator" => "business-data-initiator",
        "business-data-initiator-cucumber" => "business-data-initiator-cucumber",
        "business-data-processors" => "business-data-processors",
        "business-data-processors-cucumber" => "business-data-processors-cucumber",
        "business-data-publishers" => "business-data-publishers",
        "business-data-publishers-cucumber" => "business-data-publishers-cucumber",
        "business-data-scheduler" => "business-data-scheduler",
        "business-data-scheduler-cucumber" => "business-data-scheduler-cucumber",
        "inrix-adaptor-acceptance-tests" => "inrix-adaptor-acceptance-tests",
        "inrix-adaptor-webapp" => "inrix-adaptor-webapp",
        "public-feeds-adaptor" => "public-feeds-adaptor",
        "public-feeds-adaptor-acceptance-tests" => "public-feeds-adaptor-acceptance-tests",
        "sitemap-adaptor" => "sitemap-adaptor",
        "sitemap-adaptor-acceptance-tests" => "sitemap-adaptor-acceptance-tests",
        "tcam-adaptor" => "tcam-adaptor",
        "tcam-adaptor-cucumber" => "tcam-adaptor-cucumber",
        "weather-warnings-adaptor" => "weather-warnings-adaptor",
        "weather-warnings-adaptor-cucumber" => "weather-warnings-adaptor-cucumber",
      },
    },
    {
      ci_root: "https://ci-app.int.bbc.co.uk/hudson/api/json",
      jobs: {
        "syndication-manager-stub" => "syndication-manager-stub",
        "syndication-manager-transform" => "syndication-manager-transform",
        "syndication-manager-webapp" => "syndication-manager-webapp",
        "syndication-manager-release" => "syndication-manager-release",
      },
    },
    {
      ci_root: "https://ci-app.test.bbc.co.uk/hudson/api/json",
      jobs: {
        "syndication-manager-build" => "syndication-manager-build",
      },
    }
    ]
});

SCHEDULER.every '10s', :first_in => 0 do |job|
  JobHealth::Job.updateUsing syn_config
end
