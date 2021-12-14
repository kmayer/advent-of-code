#!/usr/bin/env ruby

require "minitest/autorun"

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:chomp).map(&:freeze).freeze

  class Grid < Hash
    attr_accessor :width, :height, :folds

    def set(x,y)
      self[[x,y]] = "#"
      self.width = [width, x].max
      self.height = [height, y].max
    end

    def to_s
      (0..height).map do |y|
        (0..width).map do |x|
          self[[x,y]] || "."
        end.join("")
      end.join("\n")
    end

    def fold_horizontal(lines)
      grid = Grid.new
      grid.width = 0
      grid.height = 0

      keys.each do |pos|
        if pos.last < lines
          grid.set(*pos)
        else
          grid.set(pos.first, lines - (pos.last - lines).abs)
        end
      end

      grid.height = lines - 1
      grid.width = width

      grid
    end

    def fold_vertical(lines)
      grid = Grid.new
      grid.width = 0
      grid.height = 0

      keys.each do |pos|
        if pos.first < lines
          grid.set(*pos)
        else
          grid.set(lines - (pos.first - lines).abs, pos.last)
        end
      end

      grid.height = height
      grid.width = lines - 1

      grid
    end

    def fold(instruction)
      axis, lines = instruction.gsub(/^fold along /,'').split("=")

      case axis
      when "y" then fold_horizontal(lines.to_i)
      when "x" then fold_vertical(lines.to_i)
      else
        fail ArgumentError, [axis, lines].inspect
      end
    end
  end

  def parser(lines)
    grid = Grid.new
    grid.width = 0
    grid.height = 0
    folds = []

    enum = lines.each 

    loop do
      line = enum.next

      break if line.strip.empty?
      x, y = line.strip.split(",").map(&:to_i)
      grid.set(x,y)
    end

    loop do
      folds << enum.next
    end

    [grid, folds]
  end

  def setup
    @sample_input = parser(LINES)
    @input = begin 
      parser(File.read("inputs/#{File.basename(__FILE__, '.rb')}.txt").lines)
    rescue Errno::ENOENT
      []
    end
  end

  def test_render
    grid = @sample_input.first
    folds = @sample_input.last

    expected = <<~EOT.chomp
      ...#..#..#.
      ....#......
      ...........
      #..........
      ...#....#.#
      ...........
      ...........
      ...........
      ...........
      ...........
      .#....#.##.
      ....#......
      ......#...#
      #..........
      #.#........
    EOT

    assert_equal expected, grid.to_s
    assert_equal ["fold along y=7", "fold along x=5"], folds
    assert_equal 14, grid.height
    assert_equal 10, grid.width
    assert_equal 18, grid.count
  end

  def test_part1a
    grid = @sample_input.first
    folds = @sample_input.last

    grid = grid.fold(folds.first)

    expected = <<~EOT.chomp
      #.##..#..#.
      #...#......
      ......#...#
      #...#......
      .#.#..#.###
      ...........
      ...........
    EOT

    assert_equal 17, grid.count
    assert_equal expected, grid.to_s
  end

  def test_part1b
    grid = @input.first
    folds = @input.last

    grid = grid.fold(folds.first)

    assert_equal 708, grid.count
  end

  def test_part2a
    grid = @sample_input.first
    folds = @sample_input.last

    folds.each do |fold|
      grid = grid.fold(fold)
    end

    expected = <<~EOT.chomp
      #####
      #...#
      #...#
      #...#
      #####
      .....
      .....
    EOT

    assert_equal 16, grid.count
    assert_equal expected, grid.to_s
  end

  def test_part_2b
    grid = @input.first
    folds = @input.last

    folds.each do |fold|
      grid = grid.fold(fold)
    end

    expected = <<~EOT.chomp
      ####.###..#....#..#.###..###..####.#..#.
      #....#..#.#....#..#.#..#.#..#.#....#..#.
      ###..###..#....#..#.###..#..#.###..####.
      #....#..#.#....#..#.#..#.###..#....#..#.
      #....#..#.#....#..#.#..#.#.#..#....#..#.
      ####.###..####..##..###..#..#.#....#..#.
    EOT

    assert_equal 104, grid.count
    assert_equal expected, grid.to_s
  end
end
__END__
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5