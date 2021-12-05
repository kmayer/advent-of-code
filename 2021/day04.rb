#!/usr/bin/env ruby

require "minitest/autorun"

class Day04 < Minitest::Test
  Game = Struct.new(:numbers, :boards) do
    def inspect
      buf = "<Game##{object_id}...\n"
      buf << numbers.join(",")
      buf << "\n"
      buf << "---------------\n"
      boards.each do |board|
        buf << board.inspect
        buf << "\n"
        buf << "---------------\n"
      end
      buf
    end
    attr_reader :last_number, :winning_boards

    def run
      loop do
        return false if numbers.empty?
        @last_number = numbers.shift
        mark_boards_with(last_number)
        new_winners, self.boards = boards.partition { |board| board.winning? }
        if new_winners && !new_winners.empty?
          @winning_boards = new_winners
          return true
        end
      end
    end

    def mark_boards_with(number)
      boards.each do |board|
        board.mark(number)
      end
    end
  end

  Board = Struct.new(:rows) do
    def inspect
      rows.map { |row| row.map { |i| i.to_s.rjust(2) }.join(" ") }.join("\n")
    end

    def mark(number)
      rows.each do |row|
        index = row.index(number)
        if index
          row[index] = nil
          return
        end
      end
    end

    def winning?
      rows.any? { |row| row.all?(&:nil?) } ||
      (0..4).any? { |col| rows.all? { |row| row[col].nil? } }
    end

    def total
      rows.sum { |row| row.map(&:to_i).sum }
    end
  end

  def parser(lines)
    lines = lines.map(&:dup)
    game = Game.new(lines.shift.strip.split(",").map(&:to_i), [])
    lines.shift
    loop do
      break game if lines.empty?
      board = Board.new([])
      loop do
        break board if lines.empty?
        line = lines.shift.strip
        break board if line.empty?
        board.rows << line.split(/\s+/).map(&:to_i)
      end
      game.boards << board
    end
  end

  INPUT_DATA = DATA.readlines
  def setup
    @sample_input = parser(INPUT_DATA)
    @input = parser(File.read("inputs/day04.txt").lines)
  end

  def test_part1a
    game = @sample_input
    game.run
    assert_equal 1, game.winning_boards.count
    assert_equal 188, game.winning_boards.first.total
    assert_equal  24, game.last_number
  end

  def test_part1b
    game = @input
    game.run
    assert_equal 1, game.winning_boards.count
    assert_equal 916, game.winning_boards.first.total
    assert_equal  90, game.last_number
    assert_equal 82_440, 916 * 90
  end

  def test_part2a
    game = @sample_input
    while (game.boards.count > 0) && game.run do
    end
    assert_equal 1, game.winning_boards.count
    assert_equal 148, game.winning_boards.first.total
    assert_equal  13, game.last_number
    assert_equal 1924, 148 * 13
  end

  def test_part_2b
    game = @input
    while (game.boards.count > 0) && game.run do
    end
    assert_equal 1, game.winning_boards.count
    assert_equal 221, game.winning_boards.first.total
    assert_equal  94, game.last_number
    assert_equal 20774, 221 * 94
  end
end
__END__
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7