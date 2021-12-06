#!/usr/bin/env ruby

require "minitest/autorun"

class School
  attr_reader :fishes
  def initialize(fishes)
    @fishes = fishes.reduce(Hash.new(0)) { |timers, timer| timers[timer] += 1; timers }
  end

  def tick
    @fishes = fishes.reduce(Hash.new(0)) do |timers, (timer, count)|
      if timer == 0
        timers[6] += count
        timers[8] += count
      else
        timers[timer - 1] += count
      end
      timers
    end
  end

  def count
    fishes.values.sum
  end

  def timers
    fishes.flat_map {|timer, count| [timer] * count}.sort
  end
end
  
Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  def parser(lines)
    School.new(lines.first.split(",").map(&:to_i))
  end

  def setup
    @sample_input = parser(LINES)
    @input = begin 
      parser(File.read("inputs/#{File.basename(__FILE__, '.rb')}.txt").lines)
    rescue Errno::ENOENT
      []
    end
  end

  def test_fish_tick
    school = School.new([3])

    school.tick

    assert [2], school.timers
  end

  def test_fish_birth
    school = School.new([0])

    school.tick

    assert_equal [6, 8], school.timers
  end

  def test_school_tick
    school = @sample_input
    assert_equal [3,4,3,1,2].sort, school.timers

    school.tick
    assert_equal [2,3,2,0,1].sort, school.timers

    school.tick
    assert_equal [1,2,1,6,0,8].sort, school.timers
  
    school.tick
    assert_equal [0,1,0,5,6,7,8].sort, school.timers

    school.tick
    assert_equal [6,0,6,4,5,6,7,8,8].sort, school.timers
  end

  def test_part1a
    school = @sample_input
    80.times do |i|
      school.tick
    end

    assert_equal 5934, school.count
  end

  def test_part1b
    school = @input
    assert_equal 300, school.count

    80.times do |i|
      school.tick
    end

    assert_equal 362639, school.count
  end

  def test_part2a
    school = @sample_input
    assert_equal 5, school.count

    256.times do |i|
      school.tick
    end

    assert_equal 26984457539, school.count
  end

  def test_part_2b
    school = @input
    assert_equal 300, school.count

    256.times do |i|
      school.tick
    end

    assert_equal 26984457539, school.count
  end
end
__END__
3,4,3,1,2