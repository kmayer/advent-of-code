#!/usr/bin/env ruby

require "minitest/autorun"
require "forwardable"
class Day05 < Minitest::Test
  Line = Struct.new(:x1,:y1,:x2,:y2) do
    def inspect
      "<Line #{x1},#{y1} -> #{x2},#{y2}>"
    end

    def horizontal?
      y1 == y2
    end

    def vertical?
      x1 == x2
    end

    def traverse(chart)
      x_step = (x2 <=> x1)
      y_step = (y2 <=> y1)

      x = x1; y = y1

      # puts "Traversing #{inspect} (#{x_step},#{y_step})"
      while (x != x2 || y != y2) do
        chart[x, y] += 1
        # puts "Marking [#{x},#{y}] => #{chart[x,y]}"
        x += x_step
        y += y_step
      end
      chart[x, y] += 1
    end
  end

  class Chart
    extend Forwardable
    def_delegator :@chart, :filter

    def initialize
      @chart = Hash.new { |h,k| h[k] = 0 }
    end

    def [](x,y)
      @chart[[x,y]]
    end

    def []=(x,y,v)
      @chart[[x,y]] = v
    end      
  end

  LINES = DATA.readlines

  def parser(lines)
    lines
    .map(&:strip)
    .map{ |line| line.gsub(/\s+->\s+/,',').split(",").map(&:to_i) }
    .map{ |i| Line.new(*i) }
  end

  def setup
    @sample_input = parser(LINES)
    @input = parser(File.read("inputs/day05.txt").lines)
  end

  def test_part1a
    lines = @sample_input
    chart = Chart.new
    working = lines.filter { |line| line.horizontal? || line.vertical? }
    assert_equal 6, working.count
    working.each do |line|
      line.traverse(chart)
    end
    assert_equal 5, chart.filter {|k,v| v >= 2 }.count
  end

  def test_part1b
    lines = @input
    chart = Chart.new
    working = lines.filter { |line| line.horizontal? || line.vertical? }
    assert_equal 323, working.count
    working.each do |line|
      line.traverse(chart)
    end
    assert_equal 7297, chart.filter {|k,v| v >= 2 }.count
  end

  def test_part2a
    lines = @sample_input
    chart = Chart.new
    working = lines
    assert_equal 10, working.count
    working.each do |line|
      line.traverse(chart)
    end
    assert_equal 12, chart.filter {|k,v| v >= 2 }.count
  end

  def test_part_2b
    lines = @input
    chart = Chart.new
    working = lines
    assert_equal 500, working.count
    working.each do |line|
      line.traverse(chart)
    end
    assert_equal 21038, chart.filter {|k,v| v >= 2 }.count
  end
end
__END__
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2