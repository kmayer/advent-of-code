#!/usr/bin/env ruby

require "minitest/autorun"

class Position
  attr_reader :horizontal, :depth
  def initialize()
    @horizontal = 0
    @depth = 0
  end

  def exec(command)
    direction, delta = command.split
    case direction
    when "forward" then forward(delta.to_i)
    when "down" then down(delta.to_i)
    when "up" then up(delta.to_i)
    else
      fail ArgumentError, command
    end
  end

  def forward(d)
    @horizontal += d
  end

  def down(d)
    @depth += d
  end

  def up(d)
    @depth -= d
  end
end

class Position2
  attr_reader :horizontal, :depth, :aim
  def initialize()
    @horizontal = 0
    @depth = 0
    @aim = 0
  end

  def exec(command)
    direction, delta = command.split
    case direction
    when "forward" then forward(delta.to_i)
    when "down" then down(delta.to_i)
    when "up" then up(delta.to_i)
    else
      fail ArgumentError, command
    end
  end

  def forward(d)
    @horizontal += d
    @depth += d * aim
  end

  def down(d)
    @aim += d
  end

  def up(d)
    @aim -= d
  end
end

class Day02 < Minitest::Test
  def setup
    @sample_input = [
      'forward 5',
      'down 5',
      'forward 8',
      'up 3',
      'down 8',
      'forward 2',
    ]
    @input = File.read("inputs/day02.txt").lines
  end

  def test_part1a
    @position = Position.new
    @sample_input.each do |command|
      @position.exec(command)
    end
    assert_equal 15, @position.horizontal
    assert_equal 10, @position.depth
    assert_equal 150, @position.horizontal * @position.depth
  end

  def test_part1b
    @position = Position.new
    @input.each do |command|
      @position.exec(command)
    end
    assert_equal 2_105, @position.horizontal
    assert_equal 807, @position.depth
    assert_equal 1_698_735, @position.horizontal * @position.depth
  end

  def test_part2a
    @position = Position2.new
    @sample_input.each do |command|
      @position.exec(command)
    end
    assert_equal 15, @position.horizontal
    assert_equal 60, @position.depth
    assert_equal 900, @position.horizontal * @position.depth
  end

  def test_part_2b
    @position = Position2.new
    @input.each do |command|
      @position.exec(command)
    end
    assert_equal 2_105, @position.horizontal
    assert_equal 757_618, @position.depth
    assert_equal 1_594_785_890, @position.horizontal * @position.depth
  end
end