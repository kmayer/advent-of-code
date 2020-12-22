# I kept getting rows & cols mixed up.
Position = Struct.new(:col, :row)

class TobogganTraversal
  TREE = "#"
  OPEN = "."

  attr_reader :forrest, :width, :traversal
  def initialize(data, traversal = [3,1]) # x/col/right, y/row/down
    @forrest = data.split("\n")
    @width = @forrest.first.length
    @traversal = Position.new(*traversal)
  end

  def trees
    count = 0
    position = Position.new(0,0)
    loop do
      position = traverse(position)
      break count if forrest[position.row].nil?
      count += 1 if forrest[position.row][position.col] == TREE
    end
  end

  def traverse(position)
    row = position.row + traversal.row
    col = (position.col + traversal.col) % width

    Position.new(col,row)
  end
end

RSpec.describe TobogganTraversal do
  let(:data) {
    <<~FORREST
    ..##.......
    #...#...#..
    .#....#..#.
    ..#.#...#.#
    .#...##..#.
    ..#.##.....
    .#.#.#....#
    .#........#
    #.##...#...
    #...##....#
    .#..#...#.#
    FORREST
  }
  let(:traversals) { [
      [1,1],
      [3,1],
      [5,1],
      [7,1],
      [1,2],
    ]
  }

  let(:planner) { described_class.new(data) }

  it { expect(planner.trees).to eq(7) }

  it "sudden arboreal stops" do
    expect(traversals.map {|t| described_class.new(data, t).trees}).to eq([2,7,3,4,2])
    expect(traversals.map {|t| described_class.new(data, t).trees}.inject(&:*)).to eq(336)
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_3.txt", __FILE__)) }

    it { expect(planner.trees).to eq(187) }
    it { expect(traversals.map {|t| described_class.new(data, t).trees}.inject(&:*)).to eq(4_723_283_400) }
  end
end