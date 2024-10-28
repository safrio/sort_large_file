require_relative 'lib/profile'
require_relative 'lib/sorter'

profile do
  Sorter.new('sample.csv', 'output.csv').sort
end
