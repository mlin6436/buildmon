# buildmon

This is a snapshot of a well established dashboard project in the BBC to help dev teams get an idea of build status of Jenkins/Hudson jobs at a glance.

### Setup

[Dashing](http://shopify.github.io/dashing/) is the backbone of the project. Therefore, having ruby is crucial. I suggest every dev to use [rvm](https://rvm.io/rvm/basics) if possbile, the reason why you should use it and the instruciton for installing rvm can be found [here](https://github.com/mlin6436/cornerstone/blob/master/macos/install-ruby.sh). The version of ruby I use is 1.9.3, but feel free to use later versions.

Once ruby is configured, try the following commands to start the application,

```bash
$ git clone git@github.com:mlin6436/buildmon.git
$ cd buildmon
$ bundle install
$ sudo dashing start &
```

By now, the dashboard should compile fine and attempt to start. Use the url,

```
http://localhost:3030
```

While there could be complaints about endpoints, certificates and etc, you might find the answer in the following sections.

### Project Structure

```
.
├── assets
├── dashboards
│   ├── layout.erb
│   └── syn.erb
├── jobs
│   └── <job>_module.rb
├── lib
├── public
└── widgets
```

### Configuring a Job

Create a project `syn` directory in `jobs`, and also create a `<project>_<job>.rb`,

```
└── jobs
    └── syn
        └── syn_jobhealth.rb
```

Then start configuring the details of the job,

```ruby
require_relative '../jobhealth_module'
require_relative '../configuration_helper'

syn_config = Helpers::ConfigHelper.new({
    job_prefix: "syn_",
    col_count: 2,
    job_css: "medium_font",
    components: [
    {
      ci_root: "https://try.this.jenkins.url/api/json/",
      jobs: {
        "jenkins job name" => "display name"
      },
    }
    ]
});
```

And schedule the job to a frequency using the following code,

```ruby
SCHEDULER.every '10s', :first_in => 0 do |job|
  JobHealth::Job.updateUsing syn_config
end
```

### View is Everything

A view file needs to be created for the project `syn` just configured,

```
└── dashboards
    └── syn.erb
```

To display the job configured, use the following template,

```html
<div>
  <ul>
    <li data-row="1" data-col="1" data-sizex="10" data-sizey="1" >
		  <div data-id="syn_jobhealth" data-view="Buildbybuildbreakdown"></div>
    </li>
  </ul>
</div>
```

There are couple things to know about this template:

- `data-id` is the id of the widget, using `<project>_<job>`.
- `data-view` is the class name of a specific widget, which can be found in `widgets` directory.
- Specify `data-row` and `data-col` like in a table to the position where the widget will be displayed.
- Define `data-sizex` and `data-sizey` to define in which cells the widget should be positioned.

### Certificate

If the Jenkins/Hudson server uses certificate-based authentication, you will normally need to prepare 2 certificates: `ca.pem` and `personal.pem`.

`ca.pem` is a public key which can be retrieved via [ca server](http://ca.dev.bbc.co.uk/). This is not required in the BBC scenario.

`personal.pem` is a certificate assigned to individual. While you are most likely to have a `personal.p12`, which would need to be converted using the following command,

```bash
sudo openssl pkcs12 -in path/to/your/dev/cert.p12 -out path/to/cert.pem -nodes -clcerts
```

A job can use `http_helper` class to handle the HTTPS requests, given the path to `personal.pem` is correctly configured.
