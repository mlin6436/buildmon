require 'gmail'
require 'htmlentities'

# SCHEDULER.every '10s', :first_in => 0 do | job |
#   data = Hash.new
  
#   hal   = "http://openclipart.org/image/2400px/svg_to_png/187546/HAL9000_iconic_eye.png"
#   gmail = Gmail.new "buildmonitor4000@gmail.com", "sportiptv2014"
#   inbox = gmail.inbox

#   inbox.emails(:unread).each do | email |
#     coder   = HTMLEntities.new
#     md5     = Digest::MD5.hexdigest(email.from[0].to_s.downcase)

#     data[:gravatar]       = "http://www.gravatar.com/avatar/#{md5}?s=200&d=#{hal}"
#     data[:name]           = email.from[0]
#     data[:message]        = coder.encode(email.body.parts[0].decoded)

#     email.delete!

#     send_event("hawker_feed", data)
#   end
#   gmail.logout
  
# end
