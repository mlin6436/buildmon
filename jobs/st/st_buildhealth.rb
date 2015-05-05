require_relative '../buildhealth_module'
require_relative '../configuration_helper'

st_config = Helpers::ConfigHelper.new({
  job_prefix:         "st_",
    default_gravatar:   "https://recruiter.files.wordpress.com/2014/09/unicorn.jpg",
    ci_components: [{
      ci_root:  "https://jenkins.bbc.co.uk/api/json/"
    }],
    stable_build: [{
      image_url:"http://www.precisionrecruitment.co.uk/recruitment-leicester/wp-content/uploads/success2.jpg",
      committer: "Success!",
      name: ''
    }]
})

SCHEDULER.every '10s', :first_in => 0 do |job|
  BuildHealth::Job.updateUsing st_config
end
