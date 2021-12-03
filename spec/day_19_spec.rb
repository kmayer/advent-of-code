State = Struct.new(:rule, :step) do
  def current_pattern
    rule[step]
  end

  def next_step
    self[:step] += 1
  end
end

class Grammar
  attr_reader :rules
  def initialize(rules)
    @rules = Hash.new
    rules.each_line(chomp: true) do |line|
      id, rule = line.split(': ')
      case rule
      when /\"(\w)\"/ then
        @rules[id.to_i] = $1
      when /\|/ then
        subrules = rule.split(/\s+\|\s+/)
        @rules[id.to_i] = subrules.map { |sr| sr.split(" ").map(&:to_i) }
      else
        @rules[id.to_i] = rule.split(" ").map(&:to_i)
      end
    end
  end

  def state
    @stack.first
  end

  def match?(buf)
    buf = buf.split("")
    @stack = [State.new(@rules[0],0)]

    loop do
      break if buf.empty?
      break if @stack.empty?
      pattern = state.current_pattern

      case pattern
      when nil
        loop do
          @stack.shift
          break if @stack.empty?
          state.next_step
          break unless state.current_pattern.is_a?(Array)
        end
      when String
        char = buf.shift
        if char == pattern
          @stack.shift
          state.next_step
        else
          buf.unshift(char)
          loop do
            @stack.shift
            break if @stack.empty?
            if state.rule[state.step + 1].is_a?(Array)
              state.next_step
              break
            end
          end
        end
      when Integer
        @stack.unshift(State.new(@rules[pattern], 0))
      when Array
        @stack.unshift(State.new(pattern, 0))
      else
        fail [pattern, @stack].inspect
      end
    end

    buf.empty? && @stack.empty?
  end
end

RSpec.describe "Monster Messages" do
  describe Grammar do
    let(:rules) {
      <<~EOT
      0: 4 1 5
      1: 2 3 | 3 2
      2: 4 4 | 5 5
      3: 4 5 | 5 4
      4: "a"
      5: "b"
      EOT
    }

    let(:messages) {
      <<~EOT
      ababbb
      bababa
      abbbab
      aaabbb
      aaaabbb
      EOT
    }

    it { expect(Grammar.new(rules).match?("ababbb")).to be_truthy }
    it { expect(Grammar.new(rules).match?("bababa")).to be_falsey }
    it { expect(Grammar.new(rules).match?("abbbab")).to be_truthy }
    it { expect(Grammar.new(rules).match?("aaabbb")).to be_falsey }
    it { expect(Grammar.new(rules).match?("aaaabbb")).to be_falsey }

    context "problem data" do
      it "can be solved" do
        rules = File.read(File.expand_path("../fixtures/day_19_rules.txt", __FILE__))

        data = File.read(File.expand_path("../fixtures/day_19.txt", __FILE__))

        matches = data.each_line(chomp: true).filter { |line| Grammar.new(rules).match?(line) }.count

        expect(matches).to eq(nil)
      end
    end
  end
end