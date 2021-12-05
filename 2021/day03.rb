#!/usr/bin/env ruby

require "minitest/autorun"

class Day03 < Minitest::Test
  def setup
    splitter = -> (set) { set.map { |b| b.chomp.split("").map(&:to_i) } }
    @sample_input = splitter.call(%w[
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    ])
    @input = splitter.call(File.read("inputs/day03.txt").lines)
  end

  def rating(input)
    input = input.map(&:dup)
    rating = []
    index = 0
    length = input.first.length - 1
    loop do
      bitset = []
      input.each do |bits|
        return rating if index > length
        bitset << bits[index]
      end
      zeros, ones = bitset.partition(&:zero?).map(&:count)

      yield zeros, ones, rating, index, input

      index += 1
    end
    fail "Should never get here"
  end

  def gamma(input)
    rating(input) do |zeros, ones, rating|
      rating << ((zeros > ones) ? "0" : "1")
    end.join.to_i(2)
  end

  def epsilon(input)
    rating(input) do |zeros, ones, rating|
      rating << ((zeros > ones) ? "1" : "0")
    end.join.to_i(2)
  end

  def oxygen(input)
    rating(input) do |zeros, ones, _, index, input|
      input.delete_if { |bits| bits[index] == ((ones >= zeros) ? 0 : 1) }
      break input.first if input.length == 1
    end.join.to_i(2)
  end

  def co2_scrubber(input)
    rating(input) do |zeros, ones, _, index, input|
      input.delete_if { |bits| bits[index] == ((ones >= zeros) ? 1 : 0) }
      break input.first if input.length == 1
    end.join.to_i(2)
  end

  def test_part1a
    assert_equal 0b10110, gamma(@sample_input)
    assert_equal 0b01001, epsilon(@sample_input)
  end

  def test_part1b
    assert_equal 0b110111001001, gamma(@input)
    assert_equal 0b001000110110, epsilon(@input)
    assert_equal 1_997_414, 3529 * 566
  end

  def test_part2a
    assert_equal 0b10111, oxygen(@sample_input)
    assert_equal 0b01010, c02_scrubber(@sample_input)
  end

  def test_part2b
    assert_equal 0b110111110101, oxygen(@input)
    assert_equal 0b000100100001, c02_scrubber(@input)
    assert_equal 1_032_597, 3573 * 289
  end
end