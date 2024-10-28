require 'rspec'
require_relative 'lib/transaction'
require_relative 'lib/sorter'

describe Transaction do
  it 'initializes with correct attributes' do
    transaction = Transaction.new('2023-09-03T12:45:00Z', 'txn12345', 'user987', '500.25')
    expect(transaction.timestamp).to eq('2023-09-03T12:45:00Z')
    expect(transaction.transaction_id).to eq('txn12345')
    expect(transaction.user_id).to eq('user987')
    expect(transaction.amount).to eq(500.25)
  end
end

describe 'Transaction processing' do
  let(:input_file) { 'test_transactions.txt' }
  let(:output_file) { 'sorted_transactions.txt' }

  after do
    File.delete(input_file) if File.exist? input_file
    File.delete(output_file) if File.exist? output_file
  end

  it 'processes sorting correctly' do
    File.open(input_file, 'w') do |file|
      file.puts("2023-09-03T12:45:00Z,txn12345,user987,500.25")
      file.puts("2023-09-03T12:46:00Z,txn12346,user988,300.0")
      file.puts("2023-09-03T12:47:00Z,txn12347,user989,700.75")
    end

    Sorter.new(input_file, output_file).sort

    sorted_transactions = File.readlines(output_file).map(&:chomp)
    expect(sorted_transactions[0]).to eq("2023-09-03T12:47:00Z,txn12347,user989,700.75")
    expect(sorted_transactions[1]).to eq("2023-09-03T12:45:00Z,txn12345,user987,500.25")
    expect(sorted_transactions[2]).to eq("2023-09-03T12:46:00Z,txn12346,user988,300.0")
  end
end
