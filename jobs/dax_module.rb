require 'httparty'

module DaxChart
  class Job
    URI::DEFAULT_PARSER = URI::Parser.new(:UNRESERVED => URI::REGEXP::PATTERN::UNRESERVED + '|')

    def self.updateUsing ( configObject )
      config = configObject.config
      
      data_array = Array.new

      date_array = Array.new
      config[:range].downto(0) { |i| date_array.push( Date.today - i ) }

      for report in config[:reports]
        data_hash = Hash.new

        params_array = Array.new
        report[:params].each { |key, value| params_array.push(key.to_s + ":" + value.to_s)}

        for date in date_array
          if date == Date.today
            0.upto(Time.new().hour - 2) { |i| data_hash[i.to_s.rjust( 2, "0") + ":00" + " " + date.to_s] = 0 }
          else
            0.upto(23) { |i| data_hash[i.to_s.rjust( 2, "0") + ":00" + " " + date.to_s] = 0 }
          end
          
          startdate = date.to_s.gsub! "-", ""

          uri = URI.parse "https://dax-rest.comscore.eu/v1/reportitems.json?client=bbc" +
            "&site=" + config[:site] +
            "&itemid=" + report[:report_id].to_s +
            "&startdate=" + startdate +
            "&user=" + config[:user] + 
            "&password=" + config[:password] +
            "&parameters=" + params_array.join("|")

          result_json = get_hash_from_json HTTParty.get(uri).body

          next if result_json.has_key?(:ERROR)

          for row in result_json[:reportitems][:reportitem][0][:rows][:r]
            data_hash[row[:c][1] + ":00" + " " + date.to_s] = row[:c][2]
          end
        end

        point_count = [config[:point_count], data_hash.keys.length].min

        report_result = {
          data: data_hash.to_a.values_at(-point_count..-1).to_h,
          lineColor: report[:line_color]
        }

        data_array.push report_result
      end

      result = {
        dataSources: data_array,
        color: config[:color],
        chartType: config[:chart_type] || "line"
      }

      send_event(config[:job_prefix] + 'dax_chart', result)
    end
  end
end

