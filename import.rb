# city   = 'amsterdam'
# locale = 'nl'

# data_filename = "output/#{locale}_#{city}_data.json"

# puts 'JSON data file not found' unless File.exist?(data_filename)


# all_rooms = JSON.parse(File.read('output/nl_amsterdam_data.json'))

# all_rooms.each do |room|
#   unless owner = Owner.where(email: room['user_email'])
#     owner = Owner.new email: room['user_email']
#     owner.password = room['user_id']

#     owner.save!
#   end


# end
