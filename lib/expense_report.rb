class ExpenseReport
  attr_reader :data
  def initialize(data)
    @data = data.freeze
    freeze
  end

  def sum_to_2020
    data.each.with_index do |i, index|
      data[index..-1].each do |j|
        return Set.new([i,j]) if i + j == 2020
      end
    end
    
    fail NoSolutionError, data
  end

  class NoSolutionError < StandardError; end
end