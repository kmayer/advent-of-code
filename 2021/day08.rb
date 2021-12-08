#!/usr/bin/env ruby

require "minitest/autorun"
require "set"

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:freeze).freeze

  class Entry
    SEGMENTS = {
      2 => [1],
      3 => [7],
      4 => [4],
      5 => [2, 3, 5],
      6 => [0, 6, 9],
      7 => [8],
    }

    attr_reader :patterns, :output
    def initialize(patterns, output)
      @patterns = patterns # Array of entries
      @output = output # Array of 4 digit output pattern
    end

    def all
      patterns | output
    end

    def easy
      @easy ||= (patterns+output).reduce({}) { |memo, pattern|
        solutions = SEGMENTS[pattern.count].dup
        if solutions.length == 1
          memo[pattern] = solutions.first
        end
        memo
      }
    end

    def easy_output
      output.map { |pattern| easy[pattern] }.compact
    end

    # Deduction, Watson
    # Given these standard segments ...
    #    0:      1:      2:      3:      4:
    #   aaaa    ....    aaaa    aaaa    ....
    #  b    c  .    c  .    c  .    c  b    c
    #  b    c  .    c  .    c  .    c  b    c
    #   ....    ....    dddd    dddd    dddd
    #  e    f  .    f  e    .  .    f  .    f
    #  e    f  .    f  e    .  .    f  .    f
    #   gggg    ....    gggg    gggg    ....
    
    #    5:      6:      7:      8:      9:
    #   aaaa    aaaa    aaaa    aaaa    aaaa
    #  b    .  b    .  .    c  b    c  b    c
    #  b    .  b    .  .    c  b    c  b    c
    #   dddd    dddd    ....    dddd    dddd
    #  .    f  e    f  .    f  e    f  .    f
    #  .    f  e    f  .    f  e    f  .    f
    #   gggg    gggg    ....    gggg    gggg
    def complete
      @complete ||= begin
        inverted = easy.invert # switch from <pattern> => value to value => <pattern>
        remaining = (all - easy.keys) # There will always be 6 remaining
        top_left = inverted[4] - inverted[1] # "bb" & "dddd" segments

        # 5, 6 & 9 have the 2 "top_left" segments lit
        # 0, 2 & 3 do not
        # So the two new sets are evenly divided:
        five_six_nine, zero_two_three = remaining.partition {|pattern| top_left.subset?(pattern)}

        # Only one pattern has length 5 in this set, it must be the "5"
        inverted[5] = five_six_nine.find{|p| p.length == 5}
        
        # The same goes for this set, this must be "0"
        inverted[0] = zero_two_three.find{|p| p.length == 6}
    
        two_three = zero_two_three - [inverted[0]] # remove the zero from the set
        # "3" has the "cc" & "ff" segments list from the "1" display
        # "2" does not
        three, two = two_three.partition {|pattern| inverted[1].subset?(pattern)}
        inverted[2] = two.first
        inverted[3] = three.first
        
        six_nine = five_six_nine - [inverted[5]] # remove the five from the set
        # Same as above for 2 & 3, "9" has "cc" & "ff" lit
        # "6" does not
        nine, six = six_nine.partition {|pattern| inverted[1].subset?(pattern)}
        inverted[6] = six.first
        inverted[9] = nine.first
    
        # Invert back to <pattern> => value
        inverted.invert

        # QED
      end
    end

    def complete_output
      output.map {|pattern| complete[pattern]}.map(&:to_s).join.to_i
    end
  end

  def parser(lines)
    lines.map { |line|
      patterns, output = line.split(/\s+\|\s+/)
      Entry.new(
        patterns.split(/\s+/).map{|p| p.split("")}.map(&:to_set), 
          output.split(/\s+/).map{|p| p.split("")}.map(&:to_set))
    }
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
    entries = @sample_input

    assert_equal 26, entries.flat_map(&:easy_output).count
  end

  def test_part1b
    entries = @input
    
    assert_equal 288, entries.flat_map(&:easy_output).count
  end

  def test_complete
    entry = @sample_input.first

    expected = {
      'acedgfb' => 8,
      'cdfbe' => 5,
      'gcdfa' => 2,
      'fbcad' => 3,
      'dab' => 7,
      'cefabd' => 9,
      'cdfgeb' => 6,
      'eafb' => 4,
      'cagedb' => 0,
      'ab' => 1,
    }.transform_keys {|key| key.split('').to_set }

    assert_equal expected.count, entry.complete.count

    expected.each do |key,value|
      assert_equal value, entry.complete[key]
    end
  end

  def test_part2a
    entries = @sample_input

    assert_equal [5353, 8394, 9781, 1197, 9361, 4873, 8418, 4548, 1625, 8717, 4315], entries.map(&:complete_output)
    assert_equal 5353 + 61229, entries.map(&:complete_output).sum
  end

  def test_part_2b
    entries = @input

    assert_equal 940724, entries.map(&:complete_output).sum
  end
end
__END__
acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce