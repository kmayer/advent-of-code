module JoltageAdapter
  module_function

  def chain(outlet_joltage, adapters, device)
    [outlet_joltage, *adapters, device].sort
  end

  def chains(adapter_chain)
    device = adapter_chain.last
    memo = Hash.new
    memo[0] = 1 # There's always only 1 way to get "here"

    adapter_chain.each do |j|
      memo[j] ||= ((j-3)..(j-1)).reduce(0) { |sum, i| sum + memo[i].to_i }
    end

    memo[device]
  end

  def chain_distribution(adapter_chain)
    adapter_chain    
      .each_cons(2)
      .map { |x,y| y - x }
      .group_by(&:itself)
      .map { |k,v| [k, v.count]}
      .to_h
  end
end