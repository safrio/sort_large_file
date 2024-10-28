require 'securerandom'
require 'time'

target_size = 1 * 1024 * 1024 * 1024 # 1 GB
file_path = 'sample.csv'

File.open(file_path, 'w') do |file|
  current_size = 0

  while current_size < target_size
    timestamp = Time.now.utc.iso8601
    transaction_id = "txn#{SecureRandom.hex(4)}"
    user_id = "user#{SecureRandom.hex(4)}"
    amount = rand(0..1000000).to_f

    line = "#{timestamp},#{transaction_id},#{user_id},#{amount}\n"

    file.write(line)

    current_size += line.bytesize
  end
end

puts 'Done'
