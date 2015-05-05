require_relative '../jobhealth_module'
require_relative '../configuration_helper'

st_config = Helpers::ConfigHelper.new({
    job_prefix: "st_",
    col_count: 3,
    job_css: "medium_font",
    components: [
    {
      ci_root: "https://jenkins.bbc.co.uk/api/json/",
      jobs: {
        "bbc-search-adaptor" => "bbc search adaptor",
        "bbc-search-adaptor-cucumber" => "bbc-search-adaptor-cucumber",
        "ace" => "ace",
        "business-data-api" => "business-data-api",
      },
    }]
});

SCHEDULER.every '10s', :first_in => 0 do |job|
  JobHealth::Job.updateUsing st_config
end
