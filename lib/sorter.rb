require_relative 'merge_sort'
require_relative 'transaction'

class Sorter
  AMOUNT_RANGE_PER_BUCKET = 1_000
  TMP_DIR = "#{Dir.pwd}/tmp"

  def initialize(input_file, output_file)
    @input_file = input_file
    @output_file = output_file
    @max_amount = 0.0
    @files = {}

    at_exit do
      @files.each { |_, v| v.close }
      `rm #{TMP_DIR}/*`
    end
  end

  def sort
    puts 'Looking for the max amount'
    get_max_amount
    puts 'Creating descriptors'
    create_descriptors
    puts 'Spliting on buckets'
    split_on_buckets
    puts 'Sorting buckets'
    sort_buckets
    puts 'Combining result'
    combine_sorted
    puts 'Done'
  end

  private

  def get_max_amount
    File.open(@input_file, 'r') do |file|
      file.each_line.with_index do |line, i|
        amount = line.chomp.split(',')[3].to_f
        @max_amount = amount if amount > @max_amount
      end
    end
  end

  def split_on_buckets
    File.open(@input_file, 'r') do |file|
      file.each_line do |line|
        timestamp, transaction_id, user_id, amount = line.chomp.split(',')
        key = amount.to_i / AMOUNT_RANGE_PER_BUCKET * AMOUNT_RANGE_PER_BUCKET
        @files[key].puts([timestamp, transaction_id, user_id, amount].join(','))
      end
    end
  end

  def create_descriptors
    current_range_start = 0
    while current_range_start <= @max_amount
      current_range_end = current_range_start + AMOUNT_RANGE_PER_BUCKET
      @files[current_range_start] = File.open("#{TMP_DIR}/#{current_range_start}", 'w+')
      current_range_start = current_range_end
    end
  end

  def sort_buckets
    @files.each do |fn, descriptor|
      transactions = []
      descriptor.rewind
      descriptor.each_line do |line|
        timestamp, transaction_id, user_id, amount = line.chomp.split(',')
        transactions << Transaction.new(timestamp, transaction_id, user_id, amount)
      end
      sort_and_write(fn, transactions)
    end
  end

  def sort_and_write(fn, transactions)
    sorted_transactions = MergeSort.new.sort(transactions)
    sorted_file = File.open(sorted_fn(fn), 'w')
    sorted_transactions.each do |transaction|
      sorted_file.puts([transaction.timestamp, transaction.transaction_id, transaction.user_id, transaction.amount].join(','))
    end
    sorted_file.close
  end

  def combine_sorted
    result_file = File.open(@output_file, 'w')
    @files.reverse_each do |fn, _|
      sorted_file = File.open(sorted_fn(fn), 'r')
      sorted_file.each_line do |line|
        result_file.puts line
      end
      sorted_file.close
    end
    result_file.close
  end

  def sorted_fn(fn)
    "#{TMP_DIR}/#{fn}_sorted"
  end
end
