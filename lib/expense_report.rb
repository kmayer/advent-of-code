class ExpenseReport
  def sum_to_2020(data)
    sums_to(2020, 2, data, [])
  end

  # total<Integer>: values must add up to it
  # take<Integer>: the number of values to use
  # data<Array>: the candidate data set
  # values<Array>: subset of candidate values, so far
  # returns<Set>: set of values, or nil if not found
  def sums_to(total, take, data, values = [])
    data.each.with_index do |i, index|
      if take > 2 # Recursion
        new_values = sums_to(total, take - 1, data[index..-1], values + [i])
      else # Base case
        new_values = sum_of_values_is(total, data[index..-1], values + [i])
      end
      return new_values if new_values
    end
    
    nil
  end

  def sum_of_values_is(total, data, values)
    data.each do |j|
      new_values = values + [j]
      return Set.new(new_values) if new_values.inject(&:+) == total
    end

    nil
  end
end