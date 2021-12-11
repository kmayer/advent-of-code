#!/usr/bin/env ruby

require "minitest/autorun"
require "set"

class Octopus
  attr_reader :pos
  attr_accessor :energy

  def initialize(coordinates, energy)
    @pos = coordinates
    @energy = energy
    @flashed = false
  end

  def inspect
    "#<Octopus #{pos}@#{energy}>"
  end

  def row
    @row ||= pos.first
  end

  def col
    @col ||= pos.last
  end

  def neighbors(grid)
    neighboring_positions.map { grid[_1] }.compact
  end

  def neighboring_positions
    @neighboring_positions ||= ((row-1)..(row+1)).flat_map {|r| ((col-1)..(col+1)).map {|c| [r,c] } }.reject{ _1 == pos }
  end

  def step
    self.energy += 1
  end

  def flashed?
    @flashed
  end

  def flashing?
    energy > 9 && !flashed?
  end

  def flash(grid)
    return unless flashing?

    neighbors(grid).each(&:step)

    @flashed = true
  end

  def reset
    return false unless energy > 9

    @flashed = false

    self.energy = 0
  end
end

class Grid < Hash
  def tick
    values.each(&:step)

    while values.any?(&:flashing?) do
      values.each do |octo| octo.flash(self); end
    end

    values.filter(&:reset).count
  end

  def energies
    values.sort_by(&:pos).map(&:energy)
  end
end

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  def parser(lines)
    Grid.new.tap do |grid|
      lines.map(&:strip).each.with_index do |line, row|
        line.split("").each.with_index do |energy, col|
          pos = [row, col]
          grid[pos] = Octopus.new(pos, energy.to_i)
        end
      end
    end
  end

  def setup
    @sample_input = parser(LINES)
    @input = parser(<<~EOT.each_line.to_a)
      5421451741
      3877321568
      7583273864
      3451717778
      2651615156
      6377167526
      5182852831
      4766856676
      3437187583
      3633371586    
    EOT
  end

  def test_octo_neighboring_positions
    subject = Octopus.new([0,0], 0)

    expected = [
      [-1,-1],[-1,0],[-1,1],
      [ 0,-1],       [ 0,1],
      [ 1,-1],[ 1,0],[ 1,1],
    ]

    assert_equal expected, subject.neighboring_positions
  end

  def test_octo_neighbors
    subject = Octopus.new([0,0], 9)

    neighbor = Octopus.new([0,1], 8)

    grid = {
      [0,0] => subject,
      [0,1] => neighbor
     }

    assert_equal [8], subject.neighbors(grid).map(&:energy)
  end

  def test_octo_step
    subject = Octopus.new([0,0], 5)

    neighbor = Octopus.new([0,1], 8)

    grid = {
      [0,0] => subject,
      [0,1] => neighbor
     }

     subject.step

     assert_equal 6,subject.energy

     assert !subject.flashing?

     subject.energy = 10
     assert subject.flashing?
  end

  def test_octo_flash
    subject = Octopus.new([0,0], 9)
    assert !subject.flashing?

    neighbor = Octopus.new([0,1], 8)

    grid = {
      [0,0] => subject,
      [0,1] => neighbor
    }

    subject.flash(grid)

    assert_equal 8, neighbor.energy

    subject.step
    assert subject.flashing?

    subject.flash(grid)

    assert !subject.flashing?
    assert subject.flashed?
    assert_equal 9, neighbor.energy

    subject.reset
    
    assert_equal 0, subject.energy
    assert !subject.flashing?
    assert !subject.flashed?
  end       

  def test_grid_tick
    counter = 0

    grid = parser(<<~EOT.each_line.to_a)
      11111
      19991
      19191
      19991
      11111
    EOT

    expected = parser(<<~EOT.each_line.to_a)
      34543
      40004
      50005
      40004
      34543
    EOT
    
    # 1 step
    counter += grid.tick

    assert_equal expected.energies, grid.energies
    assert_equal 9, counter

    expected = parser(<<~EOT.each_line.to_a)
      45654
      51115
      61116
      51115
      45654
    EOT
    
    counter += grid.tick

    assert_equal expected.energies, grid.energies
    assert_equal 9, counter
  end

  def test_part1a
    grid = @sample_input
    counter = 0

    expected = parser(<<~EOT.each_line.to_a)
      6594254334
      3856965822
      6375667284
      7252447257
      7468496589
      5278635756
      3287952832
      7993992245
      5957959665
      6394862637
    EOT

    counter += grid.tick

    assert_equal expected.energies, grid.energies
    assert_equal 0, counter

    expected = parser(<<~EOT.each_line.to_a)
      8807476555
      5089087054
      8597889608
      8485769600
      8700908800
      6600088989
      6800005943
      0000007456
      9000000876
      8700006848
    EOT

    counter += grid.tick

    assert_equal expected.energies, grid.energies
    assert_equal expected.energies.filter(&:zero?).count, counter

    8.times do counter += grid.tick; end

    assert_equal 204, counter
  end

  def test_part1b
    grid = @input
    counter = 0

    100.times do counter += grid.tick; end

    assert_equal 1673, counter
  end

  def test_part2a
    grid = @sample_input

    step = 200.times do |i|
      break i if grid.energies.all?(&:zero?)
      grid.tick
    end

    assert_equal 195, step
  end

  def test_part_2b
    grid = @input

    step = 1000.times do |i|
      break i if grid.energies.all?(&:zero?)
      grid.tick
    end

    assert_equal 279, step
  end
end
__END__
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526