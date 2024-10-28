class MergeSort
  attr_reader :min, :max

  def initialize
    @min = 0.0
    @max = 0.0
  end

  def sort(transactions)
    arr_size = transactions.size

    return transactions if arr_size <= 1

    mid = arr_size / 2
    left_half = sort(transactions[0...mid])
    right_half = sort(transactions[mid...arr_size])

    merge(left_half, right_half)
  end

  def merge(left, right)
    if right.empty?
      return left
    end

    if left.empty?
      return right
    end

    sorted = []
    until left.empty? || right.empty?
      @min = left.first.amount if @min > left.first.amount
      @min = right.first.amount if @min > right.first.amount

      @max = left.first.amount if @max < left.first.amount
      @max = right.first.amount if @max < right.first.amount

      sorted << (left.first.amount >= right.first.amount ? left.shift : right.shift)
    end
    sorted.concat(left).concat(right)
  end
end
