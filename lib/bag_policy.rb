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
