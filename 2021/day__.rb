#!/usr/bin/env ruby

require "minitest/autorun"

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  def parser(lines)
    lines
  end

  def setup
    @sample_input = parser(LINES)
    @input = begin 
      parser(File.read("inputs/#{File.basename(__FILE__, '.rb')}.txt").lines)
    rescue Errno::ENOENT
      []
    end
  end

  def test_part1a
    puts @sample_input.inspect
  end

  def test_part1b
  end

  def test_part2a
  end

  def test_part_2b
  end
end
__END__