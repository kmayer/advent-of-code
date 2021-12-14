#!/usr/bin/env ruby

require "minitest/autorun"

class CodeLine
  class IncompleteError < StandardError; end
  class CorruptedError < StandardError; end

  CLOSING = {
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">",
  }

  CLOSING_TOKENS = CLOSING.values

  attr_reader :corrupted

  def initialize(chunks)
    @chunks = chunks
    @parsed = false
  end

  def inspect
    "#<CodeLine @chunks=#{@chunks.join} @parsed=#{@parsed} @corrupted=#{@corrupted}>"
  end

  def consume(chunks)
    # $stderr.puts "#consume(#{chunks})"

    token = chunks.shift

    while !chunks.empty? do
      return chunks unless chunks.is_a?(Array)

      head = chunks.first

      if CLOSING_TOKENS.include?(head)
        if CLOSING[token] == head
          return chunks[1..-1]
        else
          @corrupted = head
          return :CORRUPTED
        end
      else
        chunks = consume(chunks)
      end
    end

    return :INCOMPLETE if token
  end

  def parsed
    # If the top-level result is an empty list, then :VALID, else, whatever
    # non-array value is returned
    @parsed ||= ((consumed = consume(@chunks)).empty?) ? :VALID : consumed
  end

  def valid?
    parsed == :VALID?
  end

  def incomplete?
    parsed == :INCOMPLETE
  end

  def corrupted?
    parsed == :CORRUPTED
  end
end

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:chomp).map(&:freeze).freeze

  def parser(lines)
    lines.map { |line| CodeLine.new(line.strip.split("")) }
  end

  def setup
    @sample_input = parser(LINES)
    @input = begin 
      parser(File.read("inputs/#{File.basename(__FILE__, '.rb')}.txt").lines)
    rescue Errno::ENOENT
      []
    end
  end

  def test_parser_incomplete
    assert_equal :INCOMPLETE, CodeLine.new(["["]).parsed

    assert_equal :INCOMPLETE, CodeLine.new("[({(<(())[]>[[{[]{<()<>>".split("")).parsed
  end

  def test_parser_valid
    assert_equal :VALID, CodeLine.new("[]".split("")).parsed

    assert_equal :VALID, CodeLine.new("([])".split("")).parsed

    assert_equal :VALID, CodeLine.new("{()()()}".split("")).parsed

    assert_equal :VALID, CodeLine.new("<([{}])>".split("")).parsed

    assert_equal :VALID, CodeLine.new("[<>({}){}[([])<>]]".split("")).parsed

    assert_equal :VALID, CodeLine.new("(((((((((())))))))))".split("")).parsed
  end

  def test_parser_corrupted
    line = CodeLine.new("[>".split(""))

    assert_equal :CORRUPTED, line.parsed
    assert_equal ">", line.corrupted

    line = CodeLine.new("(]".split(""))

    assert_equal :CORRUPTED, line.parsed
    assert_equal "]", line.corrupted

    line = CodeLine.new("{()()()>".split(""))

    assert_equal :CORRUPTED, line.parsed
    assert_equal ">", line.corrupted

    line = CodeLine.new("(((()))}".split(""))

    assert_equal :CORRUPTED, line.parsed
    assert_equal "}", line.corrupted

    line = CodeLine.new("<([]){()}[{}])".split(""))

    assert_equal :CORRUPTED, line.parsed
    assert_equal ")", line.corrupted
  end

  COSTS = {
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
  }

  def test_part1a
    lines = @sample_input

    corrupted = lines.filter(&:corrupted?)

    assert_equal 5, corrupted.count

    characters = corrupted.map(&:corrupted)

    assert_equal ['}', ')', ']', ')', '>'], characters
    assert_equal 26397, characters.map{ COSTS[_1] }.sum
  end

  def test_part1b
    lines = @input
    
    corrupted = lines.filter(&:corrupted?)

    assert_equal 47, corrupted.count

    characters = corrupted.map(&:corrupted)

    assert_equal 364389, characters.map{ COSTS[_1] }.sum
  end

  def test_part2a
    lines = @sample_input

    incomplete = lines.filter(&:incomplete?)

    assert_equal 5, incomplete.count
  end

  def test_part_2b
  end
end
__END__
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]