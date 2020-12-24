class NewMath
  attr_reader :tokens
  def initialize(expr, depth = 0)
    @tokens = case expr
    when String then tokenize(expr)
    when Array then expr
    else
      fail ArgumentError, expr.inspect
    end
    @operator = :add
    @acc = 0
    @depth = depth
  end

  def eval
    loop do
      break @acc if tokens.empty?
      t = tokens.shift
      case t
      when Integer then send(@operator, t)
      when :add then @operator = t
      when :mult then @operator = t
      when :push then tokens.unshift(self.class.new(tokens).eval)
      when :pop then break @acc
      else
        fail "WUT? #{t}"
      end
    end
  end

  private

  def add(value)
    @acc += value
  end

  def mult(value)
    @acc *= value
  end

  def tokenize(expr)
    expr.scan(/\d+|\+|\*|\(|\)/).map do |token|
      case token
      when /\d+/ then token.to_i
      when '+' then :add
      when '*' then :mult
      when '(' then :push
      when ')' then :pop
      else
        fail ArgumentError, "#{expr}, #{token.inspect}"
      end
    end
  end
end

class NewNewMath < NewMath
  def eval
    loop do
      break @acc if tokens.empty?
      t = tokens.shift
      case t
      when Integer then send(@operator, t)
      when :add then @operator = t
      when :mult then 
        @operator = t
        tokens.unshift(self.class.new(tokens).eval, :pop)
      when :push then tokens.unshift(self.class.new(tokens).eval)
      when :pop then break @acc
      else
        fail "WUT? #{t}"
      end
    end
  end
end

RSpec.describe "Operation Order" do
  describe NewMath do
    it { expect(described_class.new("1 + 2").eval).to eq(3) }
    it { expect(described_class.new("1 + 2 * 3").eval).to eq(9) }
    it { expect(described_class.new("1 + 2 * 3 + 4").eval).to eq(13) }
    it { expect(described_class.new("1 + 2 * 3 + 4 * 5").eval).to eq(65)}
    it { expect(described_class.new("1 + 2 * 3 + 4 * 5 + 6").eval).to eq(71) }

    it { expect(described_class.new("(2 * 3)").eval).to eq(6) }
    it { expect(described_class.new("1 + (2 * 3)").eval).to eq(7) }
    it { expect(described_class.new("(4 * (5 + 6))").eval).to eq(44) }
    it { expect(described_class.new("1 + (2 * 3) + (4 * (5 + 6))").eval).to eq(51) }

    it { expect(described_class.new("2 * 3 + (4 * 5)").eval).to eq(26) }
    it { expect(described_class.new("5 + (8 * 3 + 9 + 3 * 4 * 3)").eval).to eq(437) }
    it { expect(described_class.new("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))").eval).to eq(12_240) }
    it { expect(described_class.new("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2").eval).to eq(13_632) }
  end

  describe NewNewMath do
    it { expect(described_class.new("1 + 2 * 3 + 4 * 5 + 6").eval).to eq(231) }
    it { expect(described_class.new("1 + (2 * 3) + (4 * (5 + 6))").eval).to eq(51) }
    it { expect(described_class.new("5 + (8 * 3 + 9 + 3 * 4 * 3)").eval).to eq(1_445) }
    it { expect(described_class.new("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))").eval).to eq(669_060) }
    it { expect(described_class.new("(2 + 4 * 9)").eval).to eq(6 * 9) } # 54
    it { expect(described_class.new("(6 + 9 * 8 + 6)").eval).to eq(15 * 14) } # 210
    it { expect(described_class.new("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6)").eval).to eq(54 * (210 + 6)) } # 11_664
    it { expect(described_class.new("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2").eval).to eq(23_340) }
  end

  context "problem data" do
    it "adds up" do
      data = File.read(File.expand_path("../fixtures/day_18.txt", __FILE__))

      sums = data.each_line(chomp: true).map { |expr| NewMath.new(expr).eval }

      expect(sums.sum).to eq(5_374_004_645_253)
    end

    it "adds up, too" do
      data = File.read(File.expand_path("../fixtures/day_18.txt", __FILE__))

      sums = data.each_line(chomp: true).map { |expr| NewNewMath.new(expr).eval }

      expect(sums.sum).to eq(88_782_789_402_798)
    end
  end
end