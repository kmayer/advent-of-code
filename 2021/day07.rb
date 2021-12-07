#!/usr/bin/env ruby

require "minitest/autorun"

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  def parser(lines)
    lines.first.split(",").map(&:to_i)
  end

  def setup
    @cache = Hash.new(0)
    @sample_input = parser(LINES)
    @input = begin 
      parser(File.read("inputs/#{File.basename(__FILE__, '.rb')}.txt").lines)
    rescue Errno::ENOENT
      []
    end
  end

  def test_part1a
    depths = @sample_input
    crabs = depths.group_by(&:itself).transform_values(&:count) # so much nicer than reduce ...
    fuel = depths.sum # worst case, Ruby doesn't have a MAX_INT, per se

    depths.min.upto(depths.max) { |target| fuel = [fuel, crabs.sum { |depth, count| (depth - target).abs * count }].min }
    
    assert_equal 37, fuel
  end

  def test_part1b
    depths = @input
    crabs = depths.group_by(&:itself).transform_values(&:count)
    fuel = depths.sum # worst case, Ruby doesn't have a MAX_INT, per se

    depths.min.upto(depths.max) { |target| fuel = [fuel, crabs.sum { |depth, count| (depth - target).abs * count }].min }
    
    assert_equal 356179, fuel
  end

  def sum_of(n)
    (1..n).sum
  end

  def test_part2a
    depths = @sample_input
    crabs = depths.group_by(&:itself).transform_values(&:count)
    fuel = depths.sum { |d| sum_of(d) } # worst case, Ruby doesn't have a MAX_INT, per se

    depths.min.upto(depths.max) { |target| fuel = [fuel, crabs.sum { |depth, count| sum_of((depth - target).abs) * count }].min }
    
    assert_equal 168, fuel
  end

  def test_part_2b
    depths = @input
    crabs = depths.group_by(&:itself).transform_values(&:count)
    fuel = depths.sum { |d| sum_of(d) } # worst case, Ruby doesn't have a MAX_INT, per se

    depths.min.upto(depths.max) { |target| fuel = [fuel, crabs.sum { |depth, count| sum_of((depth - target).abs) * count }].min }

    assert_equal 99788435, fuel
  end
end
__END__
16,1,2,0,4,2,7,1,2,14