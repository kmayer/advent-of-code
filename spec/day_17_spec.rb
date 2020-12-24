class State
  attr_reader :state
  def initialize(state)
    @state = state
    freeze
  end

  def inspect
    state.inspect
  end

  def to_s
    state
  end

  def inactive?
    state == "."
  end

  def active?
    state == "#"
  end
end

INACTIVE, ACTIVE = State.new("."), State.new("#")

class Cube
  attr_reader :address, :state
  attr_accessor :next_state
  def initialize(address, state = INACTIVE)
    @address = address
    @state = @next_state = state
  end

  def inspect
    "#{address.inspect}(#{state},#{next_state})"
  end

  def active?
    state.active?
  end

  def inactive?
    state.inactive?
  end

  def neighbors
    x,y,z = address
    xr = (x-1)..(x+1)
    yr = (y-1)..(y+1)
    zr = (z-1)..(z+1)
    @neighbors ||= xr.flat_map { |i| yr.flat_map { |j| zr.map { |k| [i,j,k] } } }.reject { |a| a == address }.freeze
  end

  def cycle(grid)
    if active? && !neighbors.map { |a| grid[a] }.filter(&:active?).count.between?(2,3)
      @next_state = INACTIVE
      return @next_state
    end

    if inactive? && neighbors.map { |a| grid[a] }.filter(&:active?).count == 3
      @next_state = ACTIVE
      return @next_state
    end

    @next_state = state
  end

  def apply
    fail self.inspect if next_state.nil?
    @state, @next_state = next_state, nil
  end

  class << self
    def render(grid, t: "-")
      xr,yr,zr = grid.keys.inject([0..0,0..0,0..0]) { |ranges, address|
        address.each.with_index do |v, i|
          range = ranges[i]
          next if range === v
          rmin = [range.min, v].min
          rmax = [range.max, v].max
          ranges[i] = rmin..rmax
        end
        ranges
      }
      $stderr.puts "Rendering (t = #{t}) #{[xr,yr,zr].inspect}"
      zr.each do |z|
        $stderr.puts "z=#{z}"
        xr.each do |x|
          $stderr.puts yr.map { |y| grid[[x,y,z]].state.to_s}.join
        end
      end
    end

    def grid(data)
      Hash.new { |g, address| g[address] = new(address, INACTIVE) }.tap do |grid|
        data.each_line(chomp: true).with_index do |line, x|
          line.split("").each.with_index do |cell, y|
            cube = new([x,y,0], ((cell == "#") ? ACTIVE : INACTIVE))
            grid[cube.address] = cube
          end
        end

        # populate the initial space with all immediate neighbors
        grid.values.filter(&:active?).each do |cell|
          cell.neighbors.each do |address|
            grid[address] # will create if it doesn't exist
          end
        end
      end
    end
  end
end

class HyperCube < Cube
  def neighbors
    x,y,z,w = address
    xr = (x-1)..(x+1)
    yr = (y-1)..(y+1)
    zr = (z-1)..(z+1)
    wr = (w-1)..(w+1)
    @neighbors ||= xr.flat_map { |i| 
      yr.flat_map { |j| 
        zr.flat_map { |k| 
          wr.map { |l| 
            [i,j,k,l] 
      } } } }
      .reject { |a| a == address }.freeze
  end

  class << self
    def grid(data)
      Hash.new { |g, address| g[address] = new(address, INACTIVE) }.tap do |grid|
        data.each_line(chomp: true).with_index do |line, x|
          line.split("").each.with_index do |cell, y|
            cube = new([x,y,0,0], ((cell == "#") ? ACTIVE : INACTIVE))
            grid[cube.address] = cube
          end
        end

        # populate the initial space with all immediate neighbors
        grid.values.filter(&:active?).each do |cell|
          cell.neighbors.each do |address|
            grid[address] # will create if it doesn't exist
          end
        end
      end
    end

    def render(grid, t: "-")
      xr,yr,zr,wr = grid.keys.inject([0..0,0..0,0..0,0..0]) { |ranges, address|
        address.each.with_index do |v, i|
          range = ranges[i]
          next if range === v
          rmin = [range.min, v].min
          rmax = [range.max, v].max
          ranges[i] = rmin..rmax
        end
        ranges
      }
      $stderr.puts "Rendering (t = #{t}) #{[xr,yr,zr,wr].inspect}"
      wr.each do |w|
        zr.each do |z|
          $stderr.puts "z=#{z}, w=#{w}"
          xr.each do |x|
            $stderr.puts yr.map { |y| grid[[x,y,z,w]].state.to_s}.join
          end
        end
      end
    end

  end
end

RSpec.describe "Conway Cubes" do
  describe Cube do
    it "has a an address" do
      cube = Cube.new([0,0,0])

      expect(cube.address).to eq([0,0,0])
    end

    it "has an initial state" do
      cube = Cube.new([0,0,0])

      expect(cube.state).to be_inactive

      cube = Cube.new([0,0,0], ACTIVE)
      expect(cube.state).to be_active
    end

    it "has a next_state" do
      cube = Cube.new([0,0,0])

      cube.next_state = ACTIVE

      expect(cube.next_state).to be_active
    end

    it "can change state" do
      cube = Cube.new([0,0,0], INACTIVE)

      cube.next_state = ACTIVE
      cube.apply

      expect(cube.state).to be_active
    end

    it "has a set of neighbors" do
      cube = Cube.new([0,0,0])

      expect(cube.neighbors.length).to eq(26)
    end

    it "If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive." do
      grid = Cube.grid("")

      this = Cube.new([1,1,1], ACTIVE)
      grid[this.address] = this

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([9,9,9], ACTIVE)
      grid[cube.address] = cube
      cube = Cube.new([-9,-9,-9], INACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([0,0,1], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([0,1,0], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_active

      cube = Cube.new([1,0,0], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_active

      cube = Cube.new([0,0,0], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive
    end

    it "If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active. Otherwise, the cube remains inactive." do
      grid = Cube.grid("")

      this = Cube.new([1,1,1], INACTIVE)

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([0,0,1], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([0,1,0], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive

      cube = Cube.new([1,0,0], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_active

      cube = Cube.new([1,0,1], ACTIVE)
      grid[cube.address] = cube

      expect(this.cycle(grid)).to be_inactive
    end
  end

  context "an infinite grid" do
    it "after 6 cycles" do
      data = 
        <<~EOT
        .#.
        ..#
        ###
        EOT
  
      grid = Cube.grid(data)

      # Cube.render(grid, t: 0)

      (1.upto(6)).each do |t|
        grid.values.each do |cell|
          cell.cycle(grid)
        end
        grid.values.each(&:apply)
  
        # Cube.render(grid, t: t)          
      end

      expect(grid.values.filter(&:active?).count).to eq(112)
    end

    it "problem data: after 6 cycles" do
      data = 
        <<~EOT
        #.#####.
        #..##...
        .##..#..
        #.##.###
        .#.#.#..
        #.##..#.
        #####..#
        ..#.#.##
        EOT
  
      grid = Cube.grid(data)

      # Cube.render(grid, t: 0)

      (1.upto(6)).each do |t|
        grid.values.each do |cell|
          cell.cycle(grid)
        end
        grid.values.each(&:apply)
  
        # Cube.render(grid, t: t)          
      end

      expect(grid.values.filter(&:active?).count).to eq(353)
    end
  end

  describe HyperCube, slow: true do
    it "test data: after 6 cycles" do
      data = 
        <<~EOT
        .#.
        ..#
        ###
        EOT
  
      grid = HyperCube.grid(data)

      # HyperCube.render(grid, t: 0)

      (1.upto(6)).each do |t|
        grid.values.each do |cell|
          cell.cycle(grid)
        end
        grid.values.each(&:apply)
  
        # HyperCube.render(grid, t: t)          
      end

      expect(grid.values.filter(&:active?).count).to eq(848)
    end

    it "problem data: after 6 cycles" do
      data = 
        <<~EOT
        #.#####.
        #..##...
        .##..#..
        #.##.###
        .#.#.#..
        #.##..#.
        #####..#
        ..#.#.##
        EOT
  
      grid = HyperCube.grid(data)

      # HyperCube.render(grid, t: 0)

      (1.upto(6)).each do |t|
        grid.values.each do |cell|
          cell.cycle(grid)
        end
        grid.values.each(&:apply)
  
        # HyperCube.render(grid, t: t)          
      end

      expect(grid.values.filter(&:active?).count).to eq(2472)
    end
  end  
end