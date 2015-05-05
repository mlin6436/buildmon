require_relative './http_helper'
require 'uri'

module Ops
  class Job
    def self.updateUsing ( configObject )
      config = configObject.config
      result_hash = { }

      if config[:color]
        result_hash[:color] = config[:color]
      end
      
      jira_url = "https://jira.dev.bbc.co.uk/rest/api/2/search?jql=" + config[:jql_args].join

      response = `curl -k --cert #{ENV['HOME']}/.subversion/svn.pem '#{jira_url}' 2>/dev/null`
      if !response
        p "Invalid response from: `curl -k --cert #{ENV['HOME']}/.subversion/svn.pem '#{jira_url}' 2>/dev/null`"
        return
      end

      response_json = JSON.parse(response);
      if response_json["errors"]
        p "Invalid JQL call: " + response_json["errorMessages"].join
        return
      end

      if response_json["total"].eql? 0
        result_hash[:msg] = "There are no future "+config[:env]+" tickets Scheduled"
        result_hash[:msgSummary] = ""
        result_hash[:msgIcon] = "fa fa-coffee msg-icon"
        send_event(config[:job_prefix] + "ticket", result_hash)
        return
      end
      
      release_num = config[:nth_release] || 0
      issue = response_json["issues"][[release_num, response_json["total"] - 1].min]
      
      now = DateTime.now
      launch_date = DateTime.parse(issue["fields"]["customfield_10288"])
      end_date = DateTime.parse(issue["fields"]["customfield_10289"])
      rpm_date = self.getRpmDate launch_date

      transition = false
      if (issue["fields"]["assignee"]["name"] == "livesite_deploys") ||
          (issue["fields"]["assignee"]["name"] == "platform.release.managers")
        transition = true
      end
      
      ticket = issue["key"]
      summary = issue["fields"]["summary"]
      
      status = issue["fields"]["status"]["name"]
      status_count = self.getStatusCount status, transition

      if status == "In Progress"
        msg = "<b>"+ticket+"</b> is in progress..."
        msg_icon = "fa-spin fa fa-refresh msg-icon"
      elsif status == "Resolved"
        msg = "<b>"+ticket+"</b> has been deployed to "+config[:env]
        msg_icon = "fa fa-check msg-icon"
      end
      
      if transition or now > rpm_date
        status_end = config[:env] == "Stage" ? " goes to Stage" : " goes Live"
        status_msg = "<p>Until <b>"+ticket+"</b>"+status_end
        countdown_date = launch_date
      elsif status_count == 0 and now > launch_date
        should_flash = true
        status_msg = '<p>RPMs have not been done for <b>'+ticket+'</b>!'
        countdown_date = rpm_date
      else
        status_msg = '<p>To get RPMs ready for <b>'+ticket+'</b>...'
        countdown_date = rpm_date
      end

      if status_count == 1 and now > launch_date
        msg = "<b>"+ticket+"</b> is scheduled and awaiting deployment..."
        msg_icon = "fa fa-calendar msg-icon"
      end
      
      if msg
        result_hash[:msg] = msg 
        result_hash[:msgSummary] = summary
        result_hash[:msgIcon] = msg_icon
      else
        result_hash[:countdownDate] = countdown_date.to_s
        result_hash[:shouldFlash] = should_flash
        result_hash[:timerSummary] = status_msg
        result_hash[:ticketSummary] = summary
      end
      result_hash[:statusCount] = status_count

      send_event(config[:job_prefix] + "ticket", result_hash)
    end

    def self.getRpmDate( date )
      rpm_date = date - 1
      rpm_date = rpm_date.to_date
      while ((rpm_date.wday.eql? 0) || (rpm_date.wday.eql? 6)) do
        rpm_date = rpm_date - 1
      end
      return DateTime.new(rpm_date.to_date.year, rpm_date.to_date.month, rpm_date.to_date.day, 14)
    end

    def self.getStatusCount( status, transition )
      status_count = 0
      if transition or status == "Scheduled"
        status_count = 1
      elsif status == "In Progress"
        status_count = 2
      elsif status == "Resolved"
        status_count = 3
      end
      return status_count
    end
  end
end
