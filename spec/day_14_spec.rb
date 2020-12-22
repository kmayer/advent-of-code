class Docking
  attr_reader :onbits, :offbits
  def initialize
    @mem = Hash.new
    @onbits =  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX".tr("X","0").to_i(2)
    @offbits = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX".tr("X","1").to_i(2)
  end

  def sum
    @mem.values.sum
  end

  def [](addr)
    @mem[addr]
  end

  def run(data)
    data.each_line do |line|
      case line
      when /^mask = ([01X]+)/
        self.mask = Regexp.last_match(1)
      when /^mem\[(\d+)\] = (\d+)/
        self[Regexp.last_match(1).to_i] = Regexp.last_match(2).to_i
      else
        fail ArgumentError, line
      end
    end
  end

  def []=(addr, value)
    @mem[addr] = (value | onbits) & offbits
  end

  def mask=(mask)
    @onbits =  mask.tr("X", "0").to_i(2)
    @offbits = mask.tr("X", "1").to_i(2)
  end
end

class Docking2
  attr_reader :onbits
  def initialize
    @mem = Hash.new
  end

  def sum
    @mem.values.sum
  end

  def [](addr)
    @mem[addr]
  end

  def dump
    @mem
  end

  def run(data)
    data.each_line do |line|
      case line
      when /^mask = ([01X]+)/
        self.mask = Regexp.last_match(1)
      when /^mem\[(\d+)\] = (\d+)/
        self[Regexp.last_match(1).to_i] = Regexp.last_match(2).to_i
      else
        fail ArgumentError, line
      end
    end
  end

  def map_addrs(addr, masks)
    return [addr] if masks.empty?

    bit = masks.shift

    onaddr  = addr | bit
    offaddr = addr & (0b111111111111111111111111111111111111 ^ bit)

    map_addrs(onaddr, masks.dup) + map_addrs(offaddr, masks.dup)
  end

  def mask=(mask)
    @masks = mask.split("").reverse.zip(0.step).filter {|bit| bit.first == "X"}.map(&:last).map {|bit| 2 ** bit}
    @onbits = mask.tr("X","0").to_i(2)
  end

  def []=(addr,value)
    addr |= onbits

    addrs = map_addrs(addr, @masks.dup)

    addrs.each do |addr|
      @mem[addr] = value
    end
  end
end

RSpec.describe "Docking Data" do
  describe Docking do
    it "has a mask" do
      mem = Docking.new
  
      mem.mask =                "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
      expect(mem.onbits).to  eq(0b000000000000000000000000000001000000)
      expect(mem.offbits).to eq(0b111111111111111111111111111111111101)
    end
  
    it "can write to memory" do
      mem = Docking.new
      
      mem[8] = "11".to_i
  
      expect(mem[8]).to eq(11)
    end
  
    it "can add all of the registers" do
      mem = Docking.new
      
      mem[8] = 11
      mem[7] = 101
      mem[8] = 0
      
      expect(mem.sum).to eq(101)
    end
  
    it "can mask writes" do
      mem = Docking.new
      mem.mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"
  
      mem[8] =             0b000000000000000000000000000000001011
      expect(mem[8]).to eq(0b000000000000000000000000000001001001)
      mem[7] = 101
      expect(mem[7]).to eq(0b000000000000000000000000000001100101)
      mem[8] = 0
      expect(mem[8]).to eq(0b000000000000000000000000000001000000)
  
      expect(mem.sum).to eq(165)
    end
  
    context "problem data" do
      let(:data) { File.read(File.expand_path("../fixtures/day_14.txt", __FILE__)) }
  
      it "computes the sum of all fears" do
        mem = Docking.new
        mem.run(data)
        expect(mem.sum).to eq(11_501_064_782_628)
      end
    end
  end

  describe Docking2 do
    it "does weird addressy things" do
      mem = Docking2.new

      mem.mask = "000000000000000000000000000000X1001X"
      mem[42] = 100

      expected = [26, 27, 58, 59].inject({}) { |h,v| h[v] = 100; h}
      expect(mem.dump).to eq(expected)

      mem.mask = "00000000000000000000000000000000X0XX"
      mem[26] = 1

      [16,17,18,19,24,25,26,27].inject(expected) { |h,v| h[v] = 1; h}
      expect(mem.dump).to eq(expected)
    end

    context "problem data" do
      let(:data) { File.read(File.expand_path("../fixtures/day_14.txt", __FILE__)) }
  
      it "computes the sum of all furs" do
        mem = Docking2.new
        mem.run(data)
        expect(mem.sum).to eq(5_142_195_937_660)
      end
    end

  end
end