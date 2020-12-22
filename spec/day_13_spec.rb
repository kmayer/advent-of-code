require "prime"

RSpec.describe "Shuttle Search" do
  def sequence?(t, buses)
    buses.each.with_index do |bus, i|
      next if bus == "x"
      next if i.zero?
      return false if bus - (t % bus) != i
    end
    true
  end

  context "sample data" do
    let(:data) { "7,13,x,x,59,x,31,19" }
    it "modulos" do
      departure_time = 939
      buses = data
        .split(",")
        .reject{|i| i == "x"}
        .map(&:to_i)
      expect(buses.map { |bus| [bus, (bus - departure_time % bus)] }.min_by(&:last).inject(&:*)).to eq(295)
    end

    it "contest time, brute force" do
      t = 1_068_781
      buses = data.split(",").map {|x| x == "x" ? x : x.to_i }

      expect(sequence?(t, buses)).to be_truthy

      new_t = 0.step(by: buses.first.to_i).detect {|t| sequence?(t, buses) }

      expect(new_t).to eq(t)
    end
  end

  context "problem data" do
    let(:data) { "29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,467,x,x,x,x,x,x,x,23,x,x,x,x,13,x,x,x,17,x,19,x,x,x,x,x,x,x,x,x,x,x,443,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41" }

    it "modulos" do
      departure_time = 1_000_508
      buses = data
        .split(",")
        .reject{|i| i == "x"}
        .map(&:to_i)
      expect(buses.map { |bus| [bus, (bus - departure_time % bus)] }.min_by(&:last).inject(&:*)).to eq(333)
    end

    it "contest time" do
      # I don't maths well https://dev.to/rpalo/advent-of-code-2020-solution-megathread-day-13-shuttle-search-313f
      t = 0
      busses = data.split(",").map.with_index {|x,i| next if x == "x"; [x.to_i, i]}.compact

      factors = [busses.shift.first] # prime_division.map(&:first)
      busses.each do |(bus, offset)|
        inc = factors.inject(&:*) # product of all of the prime factors
        loop do
          minutes_until_departure = bus - (t % bus)
          break t if minutes_until_departure == offset % bus # the bus leaves correctly at t + offset
          t += inc
        end
        factors.push(bus)
      end

      expect(t).to eq(690_123_192_779_524)
    end
  end
end