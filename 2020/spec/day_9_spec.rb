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
      return value if preamble.combination(2).none? { |pair| pair.inject(&:+) == value }
      preamble.shift; preamble << value
    end
  end

  def sequence(total)
    (2..data_stream.length).each do |length|
      data_stream.each_cons(length) do |seq|
        return seq if seq.inject(&:+) == total
      end
    end
  end
end

RSpec.describe XmasEncoder do
  let(:data) {
    <<~EOT
    35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576
    EOT
  }

  let(:stream) { data.each_line.map(&:chomp).map(&:to_i) }

  subject(:xmas_encoder) { described_class.new(stream) }

  it { expect(xmas_encoder.invalid(n: 5)).to eq(127) }
  it { expect(xmas_encoder.sequence(127)).to eq([15,25,47,40]) }

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_9.txt", __FILE__)) }
    
    it { expect(xmas_encoder.invalid).to eq(138_879_426) }
    it { seq = xmas_encoder.sequence(xmas_encoder.invalid); expect(seq.min + seq.max).to eq(23_761_694) }
  end
end