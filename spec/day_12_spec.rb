require "matrix"

class NavComp
  attr_reader :program, :pos, :vector
  NORTH, SOUTH, EAST, WEST, LEFT, RIGHT, FWD = *%w[N S E W L R F]

  def initialize(program)
    @program = program.each
    @pos = Vector[0,0]
    @vector = Vector[1,0]
  end

  def inspect
    "#<NavComp:#{object_id.to_s(16)} @pos=#{pos.inspect} @vector=#{vector.inspect}>"
  end

  def md
    pos.map(&:abs).sum
  end

  def step
    line = program.next
    instruction, value = line.match(/([NSEWLRF])(\d+)/).captures
    value = value.to_i

    case instruction
    when FWD then advance(vector, value)
    when NORTH then advance(Vector[0,1], value)
    when SOUTH then advance(Vector[0,-1], value)
    when EAST then advance(Vector[1,0], value)
    when WEST then advance(Vector[-1,0], value)
    when RIGHT then rotate(-value.to_i / 90)
    when LEFT then rotate(value.to_i / 90)
    else
      fail ArgumentError, [instruction, value].inspect
    end

    self    
  end

  def advance(v, value)
    @pos = pos + v * value
  end

  def rotate(tx)
    vectors = [Vector[0,1], Vector[-1,0], Vector[0,-1], Vector[1,0]]
    loop do
      break if vectors.first == vector
      vectors.rotate!
    end
    @vector = vectors.rotate(tx).first
  end
end

RSpec.describe "Rain Risk" do
  describe NavComp do
    subject(:nav_comp) { NavComp.new(nav_program) }
    let(:data) {
      <<~EOT
      F10
      N3
      F7
      R90
      F11
      EOT
    }
    let(:nav_program) { data.each_line.map(&:chomp) }
  
    it "has a position" do
      expect(nav_comp.pos).to eq(Vector[0,0])
    end

    it "has a Manhattan distance" do
      expect(nav_comp.md).to eq(0)
    end

    it "can step through the program" do
      expect(nav_comp.step.pos).to eq(Vector[10,0])
      expect(nav_comp.step.pos).to eq(Vector[10,3])
      expect(nav_comp.step.pos).to eq(Vector[17,3])
      expect(nav_comp.step.pos).to eq(Vector[17,3])
      expect(nav_comp.vector).to eq(Vector[0,-1])
      expect(nav_comp.step.pos).to eq(Vector[17,-8])
      expect { nav_comp.step }.to raise_error(StopIteration)
      expect(nav_comp.md).to eq(25)
    end
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_12.txt", __FILE__)) }
    let(:nav_program) { data.each_line.map(&:chomp) }
    subject(:nav_comp) { NavComp.new(nav_program) }

    it "can compute the things" do
      loop do
        nav_comp.step
      end
      expect(nav_comp.md).to eq(845)
    end
  end
end