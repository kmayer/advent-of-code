#!/usr/bin/env ruby

require "minitest/autorun"
require "set"
# require "debug"

class Location
  attr_reader :row, :col, :depth, :grid
  def initialize(row, col, depth, grid)
    @row = row
    @col = col
    @depth = depth
    @grid = grid
  end

  def inspect
    "[#{row},#{col}]@#{depth}"
  end

  def pos
    [row,col]
  end

  def neighbors
    [up, down, left, right].map { |pos| grid[pos] }.compact
  end

  def lowpoint?
    neighbors.all? { |neighbor| depth < neighbor.depth }
  end

  # recursion
  def basin(locations = Set.new)
    search = neighbors.reject {|loc| loc.depth < depth || loc.depth == 9 || locations.include?(loc) }.to_set

    locations << self

    if search.empty?
      locations
    else
      search.each do |loc|
        locations |= loc.basin(locations)
      end
      locations
    end
  end

  def risk
    depth + 1
  end

  private

  def up
    [row-1, col]
  end

  def down
    [row+1, col]
  end

  def left
    [row, col-1]
  end

  def right
    [row, col+1]
  end
end

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  def parser(lines)
    {}.tap do |grid|
      lines.each.with_index do |line, row|
        line.chomp.split("").each.with_index do |depth, col|
          grid[[row,col]] = Location.new(row, col, depth.to_i, grid)
        end
      end
    end
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
    grid = @sample_input

    # puts grid.filter {|pos, loc| loc.lowpoint? }

    assert_equal 15, grid.filter {|pos, loc| loc.lowpoint? }.values.map(&:risk).sum
  end

  def test_part1b
    grid = @input

    assert_equal 508, grid.filter {|pos, loc| loc.lowpoint? }.values.map(&:risk).sum
  end

  def test_part2a
    grid = @sample_input

    location = grid[[0,1]]
    assert location.lowpoint?

    assert_equal Set.new([ [0,0], [0,1], [1,0] ]), location.basin.map(&:pos).to_set

    location = grid[[0,9]]
    assert location.lowpoint?

    assert_equal 9, location.basin.map(&:pos).count

    location = grid[[2,2]]
    assert location.lowpoint?

    assert_equal 14, location.basin.map(&:pos).count

    location = grid[[4,6]]
    assert location.lowpoint?

    assert_equal 9, location.basin.map(&:pos).count

    assert_equal 1134, grid.filter {|pos, loc| loc.lowpoint? }.values.map(&:basin).sort_by(&:count).map(&:count).reverse.take(3).reduce(&:*)
  end


  def test_part_2b
    grid = @input

    lowpoints = grid.filter { |pos, loc| loc.lowpoint? }.values

    assert_equal 1564640, lowpoints.map(&:basin).map(&:count).sort.reverse.take(3).reduce(&:*)
  end
end
__END__
2199943210
3987894921
9856789892
8767896789
9899965678
