class XmasEncoder
  attr_reader :data_stream
  def initialize(stream)
    @data_stream = stream
  end

  def invalid(n: 25)
    preamble = data_stream.take(n)
    stream = data_stream.drop(n).each
    
    loop do
      value = stream.next
      return value if preamble.combination(2).all? { |pair| pair.inject(&:+) != value }
      preamble.shift; preamble << value
    end
  end

  def sequence(total)
    (2..(data_stream.length)).each do |length|
      data_stream.each_cons(length) do |seq|
        return seq if seq.inject(&:+) == total
      end
    end
  end
end