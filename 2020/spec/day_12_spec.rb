require "matrix"


class NavCompBase
  attr_reader :program, :pos, :wp
  NORTH, SOUTH, EAST, WEST, LEFT, RIGHT, FWD = *%w[N S E W L R F]
  E_V, N_V, W_V, S_V = Vector[1,0], Vector[0,1], Vector[-1,0], Vector[0,-1]
  def initialize(program, starting_pos: Vector[0,0], starting_wp: Vector[10,1])
    @program = program.each
    @pos = starting_pos
    @wp = starting_wp
    @vectors = [E_V, N_V, W_V, S_V]
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

    call(instruction, value)
  end
end

class NavComp < NavCompBase
  def advance(v, value)
    @pos = pos + v * value
  end

  def vector
    @vectors.first
  end

  def rotate(tx)
    @vectors.rotate!(tx)
  end

  def call(instruction, value)
    case instruction
    when FWD then advance(vector, value)
    when NORTH then advance(N_V, value)
    when SOUTH then advance(S_V, value)
    when EAST then advance(E_V, value)
    when WEST then advance(W_V, value)
    when RIGHT then rotate(-value.to_i / 90)
    when LEFT then rotate(value.to_i / 90)
    else
      fail ArgumentError, [instruction, value].inspect
    end

    self    
  end
end

class NavComp2 < NavCompBase
  def call(instruction, value)
    case instruction
    when FWD then advance(wp, value)
    when NORTH then advance_wp(N_V, value)
    when SOUTH then advance_wp(S_V, value)
    when EAST then advance_wp(E_V, value)
    when WEST then advance_wp(W_V, value)
    when RIGHT then rotate_wp(-value.to_i / 90)
    when LEFT then rotate_wp(value.to_i / 90)
    else
      fail ArgumentError, [instruction, value].inspect
    end

    self    
  end

  def advance(v, value)
    @pos = pos + v * value
  end

  def advance_wp(v, value)
    @wp = wp + v * value
  end

  def rotate_wp(tx)
    tx += 4 if tx < 0 # Force a counter-clockwise rotation
    tx.times do
      @wp = Vector.elements(wp.to_a.rotate.tap { |a| a[0] = -a[0] })
    end
  end
end

RSpec.describe "Rain Risk" do
  describe NavCompBase do
    subject(:nav_comp) { described_class.new([]) }
  
    it "has a position" do
      expect(nav_comp.pos).to eq(Vector[0,0])
    end

    it "has a waypoint (vector)" do
      expect(nav_comp.wp).to eq(Vector[10,1])
    end

    it "has a Manhattan distance" do
      expect(nav_comp.md).to eq(0)
    end

    it { expect { nav_comp.step }.to raise_error(StopIteration) }
  end

  describe NavComp do
    subject(:nav_comp) { described_class.new([]) }

    it "can step through the program" do
      expect(nav_comp.call("F", 10).pos).to eq(Vector[10,0])
      expect(nav_comp.call("N", 3).pos).to eq(Vector[10,3])
      expect(nav_comp.call("F", 7).pos).to eq(Vector[17,3])
      expect(nav_comp.call("R", 90).vector).to eq(Vector[0,-1])
      expect(nav_comp.call("F", 11).pos).to eq(Vector[17,-8])

      expect(nav_comp.md).to eq(25)
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

  describe NavComp2 do
    subject(:nav_comp) { described_class.new([]) }

    it "steps through the new program" do
      expect(nav_comp.call("F", 10).pos).to eq(Vector[100,10])
      expect(nav_comp.call("N", 3).wp).to eq(Vector[10,4])
      expect(nav_comp.call("F", 7).pos).to eq(Vector[170,38])
      expect(nav_comp.call("R", 90).wp).to eq(Vector[4,-10])
      expect(nav_comp.call("F", 11).pos).to eq(Vector[214,-72])

      expect(nav_comp.md).to eq(286)
    end

    context "problem data" do
      let(:data) { File.read(File.expand_path("../fixtures/day_12.txt", __FILE__)) }
      let(:nav_program) { data.each_line.map(&:chomp) }
      subject(:nav_comp) { NavComp2.new(nav_program) }

      it "computes the solution" do
        loop do
          nav_comp.step
        end
        expect(nav_comp.md).to eq(27_016)
      end  
    end
  end
end