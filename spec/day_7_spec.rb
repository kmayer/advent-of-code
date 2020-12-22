class BagRule
  attr_reader :quantity, :color_code

  def initialize(quantity, color_code)
    @quantity = quantity.freeze
    @color_code = color_code.freeze
  end

  def inspect
    "#<BagRule #{quantity} #{color_code.inspect} bag#{quantity > 1 ? 's' : nil}>"
  end

  # I'm not fond of the BagRule reaching for BagPolicy, but it is needed to
  # delay the evaluation of the color_code -> BagPolicy until all of the data
  # is loaded into the cache.
  # In an earlier iteration, +self.color_code+ and +other+ were always a BagPolicy objects
  def allows?(other)
    other = BagPolicy.find(other)
    # $stderr.puts "allows?(#{other.color_code}): #{self.inspect}"
    return true if bag_policy == other
    bag_policy.contains?(other)
  end

  def bag_policy
    @bag_policy ||= BagPolicy.find(color_code)
  end
end

class BagPolicy
  attr_reader :color_code, :rule_set

  def initialize(color_code)
    @color_code = color_code
    @rule_set = Set.new
  end

  def inspect
    "#<BagPolicy #{color_code.inspect} bags contain #{rule_set.inspect}"
  end

  def must_contain(quantity, color_code)
    rule_set << BagRule.new(quantity, color_code)
  end

  def contains?(color_code)
    # $stderr.puts "contains?(#{color_code}): #{self.inspect}"
    rule_set.any? { |rule| rule.allows?(color_code) }
  end

  def bags
    rule_set.flat_map { |rule| ([
      rule.color_code,                       # base case
      self.class.find(rule.color_code).bags, # recursive definition
     ] * rule.quantity)
     .flatten
    }
  end

  class << self
    # A little "Active Record" pattern
    def find(color_code)
      return color_code if color_code.is_a?(self)
      @@policies.fetch(color_code)
    end

    def all
      @@policies.values
    end

    def load(data)
      @@policies = Hash.new

      data.each_line do |line|
        next if line =~ /^#/
        color_code, rules = line.chomp.match(/^\s*([\w ]+) bags contain (.+)\.\s*$/).captures
        register(color_code).tap do |bag|
          break if rules == "no other bags"
          rules.split(/,\s*/).each do |rule|
            quantity, color_code = rule.match(/(\d+)\s+([\w ]+) bags?/).captures
            bag.must_contain(quantity.to_i, color_code)
          end
        end
      end
    end

    def register(color_code)
      new(color_code).tap { |policy| @@policies[color_code] = policy }
    end
  end
end

RSpec.describe BagPolicy do
  context "sample data - 1" do
    before(:each) do
      data = <<~EOT
      light red bags contain 1 bright white bag, 2 muted yellow bags.
      dark orange bags contain 3 bright white bags, 4 muted yellow bags.
      bright white bags contain 1 shiny gold bag.
      muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
      shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
      dark olive bags contain 3 faded blue bags, 4 dotted black bags.
      vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
      faded blue bags contain no other bags.
      dotted black bags contain no other bags.
      EOT

      BagPolicy.load(data)
    end

    it { 
      expect(BagPolicy.all.select {|policy| policy.contains?("shiny gold")}.map(&:color_code))
      .to match_array([
        "bright white",
        "muted yellow",
        "dark orange",
        "light red",
      ])}
  end

  context "problem data" do
    before(:each) do
      data = File.read(File.expand_path("../fixtures/day_7.txt", __FILE__))
      BagPolicy.load(data)
    end

    it { expect(BagPolicy.all.select{|p| p.contains?("shiny gold")}.count).to eq(229) }
    it { expect(BagPolicy.find("shiny gold").bags.count).to eq(6683) }
  end

  context "sample data - 2" do
    before(:each) do
      data = <<~EOT
      shiny gold bags contain 2 dark red bags.
      dark red bags contain 2 dark orange bags.
      dark orange bags contain 2 dark yellow bags.
      dark yellow bags contain 2 dark green bags.
      dark green bags contain 2 dark blue bags.
      dark blue bags contain 2 dark violet bags.
      dark violet bags contain no other bags.
      EOT

      BagPolicy.load(data)
    end

    it { expect(BagPolicy.find("shiny gold").bags.count).to eq(126) }
  end

end