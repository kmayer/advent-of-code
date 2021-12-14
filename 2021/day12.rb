#!/usr/bin/env ruby

require "minitest/autorun"
require "forwardable"
require "set"

class Cave
  def inspect
    "#<#{@label}@#{@visits}>"
  end

  def to_s
    "#{@label}@#{visits}"
  end

  def self.factory(letter)
    case letter
    when "start", "end" then BigCave.new(letter)
    when 'a'..'z' then LittleCave.new(letter)
    when 'A'..'Z' then BigCave.new(letter)
    else
      fail ArgumentError, letter
    end
  end

  attr_accessor :visits, :label
  def initialize(letter)
    @label = letter
    @visits = 0
  end

  def visit
    self.visits += 1
  end

  def end?
    label == "end"
  end
end

class BigCave < Cave
  def visited?
    false
  end
end

class LittleCave < Cave
  def visited?
    @visits > 0
  end
end

class Path
  attr_accessor :path, :visited
  def initialize(path = [])
    @path = path
    @visited = Set.new(path)
  end

  def inspect
    "#<Path##{object_id} #{path.inspect} @visited=#{visited.inspect}"
  end

  def <<(label)
    visited << label
    path << label
  end

  def visited?(label)
    visited.include?(label)
  end
end

class Graph
  extend Forwardable
  attr_accessor :hash, :nodes
  def initialize(hash = Hash.new { |h,k| h[k] = Array.new })
    @hash = hash
  end

  def_delegators :@hash, :[], :[]=, :<<, :inspect

  def paths
    self["start"]
    .flat_map { |node| paths2(node, [Path.new(["start"])])}
    .compact
    .map(&:path)
    .to_set
  end

  # Takes a node and a list of paths
  # Computes all paths from node to :end:
  def paths2(node, paths)
    $stderr.puts "paths2(#{node}, #{paths})"
    
    paths.each do |path|
      path << node
    end

    return paths if node == "end"

    self[node].flat_map { |visit|
      paths.flat_map { |path| 
        next if path.visited?(visit)
        paths2(visit, [path])
      }
    }
  end
end

Class.new(Minitest::Test) do
  def self.name
    File.basename(__FILE__, '.rb').capitalize
  end

  LINES = DATA.readlines.map(&:chomp).map(&:freeze).freeze

  def parser(lines)
    graph = Graph.new.tap { |graph|
      lines.map { |line| 
        v0, v1 = line.strip.split("-")
        graph[v0] << v1 unless v1 == "start" || v0 == "end"
        graph[v1] << v0 unless v0 == "start" || v1 == "end"
      }
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

  def test_cave_factory
    assert_instance_of BigCave, Cave.factory("start")
    assert_instance_of BigCave, Cave.factory("end")
    assert_instance_of BigCave, Cave.factory("B")
    assert_instance_of BigCave, Cave.factory("Y")
    assert_instance_of LittleCave, Cave.factory("n")
    assert_instance_of LittleCave, Cave.factory("y")
  end

  def test_little_cave_visiting
    cave = LittleCave.new("test")
    assert !cave.visited?

    cave.visit
    
    assert cave.visited?
  end

  def test_big_cave_visiting
    cave = BigCave.new("test")
    assert !cave.visited?

    cave.visit
    
    assert !cave.visited?
  end

  def test_parser
    expected = { "start"=>%w[A b], "A"=>%w[c b end], "c"=>%w[A], "b"=>%w[A d end], "d"=>%w[b] }

    assert_equal expected.inspect, @sample_input.inspect
  end

  def test_path_search_start_end
    graph = parser(["start-end"])

    # A graph of start-end, is just that
    paths = graph.paths

    assert_equal [%w[start end]].to_set, graph.paths
  end

  def test_path_search_start_A_end
    graph = parser(<<~EOT.each_line)
      start-A
      A-end
    EOT

    paths = graph.paths

    assert_equal [%w[start A end]].to_set, graph.paths
  end

  def test_path_search_start_A_B_end
    graph = parser(<<~EOT.each_line)
      start-A
      start-B
      A-B
      A-end
      B-end
    EOT

    paths = graph.paths

    expected = [
      %w[start A end], 
      %w[start B end], 
      %w[start A B end], 
      %w[start B A end],
    ].to_set

    assert_equal expected, graph.paths
  end

  def test_part1a
  end

  def test_part1b
  end

  def test_part2a
  end

  def test_part_2b
  end
end
__END__
start-A
start-b
A-c
A-b
b-d
A-end
b-end
