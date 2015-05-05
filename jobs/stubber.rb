# EVENT = "sport_jobs_health"
# STUB = [
#         "../../assets/stub/all_green.json",
#         "../../assets/stub/one_blue.json",
#         "../../assets/stub/one_red.json",
#         "../../assets/stub/mixture.json"
#        ]

# SCHEDULER.every '15s', :first_in => 0 do |job|
#   stub_data = get_hash_from_json(File.read(File.expand_path(STUB.sample, __FILE__)))
#   puts stub_data.to_json
#   send_event(EVENT, get_hash_from_json(stub_data.to_json))
# end
