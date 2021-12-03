#!/usr/bin/env ruby

require "minitest/autorun"

class Day01 < Minitest::Test
  def setup
    @sample_input = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
    @input = File.read("inputs/day01.txt").lines.map(&:to_i)
  end

  def test_part1a
    assert_equal 10, @sample_input.count
    increases = @sample_input.each_cons(2).filter { |i,j| i < j }
    assert_equal 7, increases.count
  end

  def test_part1b
    assert_equal 2_000, @input.count
    increases = @input.each_cons(2).filter { |i,j| i < j }
    assert_equal 1_583, increases.count
  end

  def test_part2a
    sum_of_triples = []
    @sample_input.each_cons(3) { |a| sum_of_triples << a.sum }
    increases = sum_of_triples.each_cons(2).filter { |i,j| i < j }
    assert_equal 5, increases.count
  end

  def test_part2b
    sum_of_triples = []
    @input.each_cons(3) { |a| sum_of_triples << a.sum }
    increases = sum_of_triples.each_cons(2).filter { |i,j| i < j }
    assert_equal 1_627, increases.count
  end
end