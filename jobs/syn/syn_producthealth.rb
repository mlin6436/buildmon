require_relative '../producthealth_module'
require_relative '../configuration_helper'

syn_config = Helpers::ConfigHelper.new({
  job_prefix: "syn_",
  col_count: 3,
  job_css: "medium_font",
  products: [
    {
      url: "https://tcam-adaptor.cloud.bbc.co.uk/status"
    }
  ]
});

SCHEDULER.every '10s', :first_in => 0 do |job|
  ProductHealth::Product.updateUsing syn_config
end
