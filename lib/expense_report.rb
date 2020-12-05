class ExpenseReport
  def sum_to_2020(data)
    sums_to(2020, 2, data)
  end

  # total<Integer>: values must add up to it
  # take<Integer>: the number of values to use
  # data<Array>: the candidate data set
  def sums_to(total, take, data)
    data.combination(take).find { |a| a.inject(&:+) == total }
  end
end