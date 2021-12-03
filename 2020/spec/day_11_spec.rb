class Seat
  FLOOR = "."
  EMPTY = "L"
  OCCUPIED = "#"

  attr_reader :address, :state, :cache
  def initialize(address, state = FLOOR, cache: nil)
    raise ArgumentError, state unless [FLOOR, EMPTY, OCCUPIED].include?(state)
    @address = address.freeze
    @state = state
    @cache = cache
  end

  def ==(other)
    address == other.address && state == other.state
  end

  def floor?
    state == FLOOR
  end

  def empty?
    state == EMPTY
  end

  def occupied?
    state == OCCUPIED
  end

  def unoccupied?
    !occupied?
  end

  def rule_set_1(seat_map)
    return OCCUPIED if empty? && adjacents.all? { |addr| seat_map[addr].nil? or seat_map[addr].unoccupied? }
    return EMPTY if occupied? && adjacents.filter { |addr| seat_map[addr]&.occupied? }.length >= 4
    state
  end

  def adjacents
    @cache ||= begin
      row = address.first
      col = address.last

      ((row-1)..(row+1)).flat_map { |r|
        ((col-1)..(col+1)).map {|c| 
          next if [r,c] == [row,col] # exclude self
          [r,c].freeze
        }.compact
      }.freeze
    end
  end

  def rule_set_2(seat_map)
    return OCCUPIED if empty? && line_of_sight(seat_map).all? { |addr| seat_map[addr].nil? or seat_map[addr].unoccupied? }
    return EMPTY if occupied? && line_of_sight(seat_map).filter { |addr| seat_map[addr]&.occupied? }.length >= 5
    state
  end

  def line_of_sight(seat_map)
    @cache ||= begin
      (-1..+1).flat_map { |vr| 
        (-1..+1).map { |vc| 
          next if vc.zero? && vr.zero?
          row = address.first
          col = address.last
          loop do
            row += vr; col += vc
            break nil if seat_map[[row,col]].nil?
            break [row, col] if !seat_map[[row,col]].floor?
          end
        }.compact
      }
    end
  end

  EMPTY_SEAT_MAP = {
    [0,0] => new([0,0]),
    [0,1] => new([0,1]),
    [0,2] => new([0,2]),

    [1,0] => new([1,0]),
    # [1,1] => "self",
    [1,2] => new([1,2]),
    
    [2,0] => new([2,0]),
    [2,1] => new([2,1]),
    [2,2] => new([2,2]),
  }.freeze

  class << self
    def build_map(data)
      Hash.new.tap do |seat_map|
        data.each_line.with_index do |line, row|
          line.chomp.split("").each.with_index do |seat, col|
            seat_map[[row,col]] = new([row,col], seat)
          end
        end
      end
    end

    # debugging
    def render(seat_map, max_row, max_col)
      (0..max_row).map { |row|
        (0..max_col).map { |col|
          seat_map[[row,col]].state 
        }.join("")
      }.join("\n")
    end

    def solution(seat_map, rule_set: :rule_set_1)
      this_seat_map = seat_map.dup
      counter = 0

      loop do
        new_seat_map = this_seat_map.inject(Hash.new) { |hash, (address, seat)| hash[address] = Seat.new(address, seat.send(rule_set, this_seat_map), cache: seat.cache); hash }

        break new_seat_map if new_seat_map == this_seat_map
        yield new_seat_map, counter if block_given?
        this_seat_map = new_seat_map

        counter += 1
        fail "counter #{counter} exceeded max" if counter > 100
      end
    end
  end
end

RSpec.describe "Seating System" do
  describe Seat do
    it "has an address" do
      seat = described_class.new([1,1])
      expect(seat.address).to eq([1,1])
    end

    it "equality" do
      seat1 = described_class.new([1,1], Seat::FLOOR)
      seat2 = described_class.new([1,1], Seat::FLOOR)

      expect(seat1).to eq(seat2)
    end

    it "can be a floor" do
      seat = described_class.new([1,1], Seat::FLOOR)

      expect(seat.floor?).to be_truthy
    end

    it "can be an empty seat" do
      seat = described_class.new([1,1], Seat::EMPTY)

      expect(seat.empty?).to be_truthy
    end

    it "can be occupied" do
      seat = described_class.new([1,1], Seat::OCCUPIED)

      expect(seat.occupied?).to be_truthy
    end

    it "has a list of adjacents" do
      seat = described_class.new([1,1])

      expect(seat.adjacents).to eq([
        [0,0],[0,1],[0,2],
        [1,0],      [1,2],
        [2,0],[2,1],[2,2]
      ])
    end

    context "rule set 1: seating rules" do  
      let(:seat_map) { Seat::EMPTY_SEAT_MAP.dup } # writable
      
      it "when empty & no occupied seats adjacent" do
        seat = described_class.new([1,1], Seat::EMPTY)
        seat_map[seat.address] = seat

        expect(seat.rule_set_1(seat_map)).to eq(Seat::OCCUPIED)
      end

      it "when occupied & >= 4 occupied seats adjacents" do
        seat = described_class.new([1,1], Seat::OCCUPIED)
        seat_map[seat.address] = seat

        seat_map[[0,0]] = described_class.new([0,0], Seat::OCCUPIED)
        seat_map[[0,1]] = described_class.new([0,1], Seat::OCCUPIED)
        seat_map[[0,2]] = described_class.new([0,2], Seat::OCCUPIED)
        
        seat_map[[1,0]] = described_class.new([1,0], Seat::OCCUPIED)

        expect(seat.rule_set_1(seat_map)).to eq(Seat::EMPTY)
      end
    end
  end

  context "first sample data set" do
    let(:seat_map) { Seat.build_map(data) }
    
    let(:data) {
      <<~EOT
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
      EOT
    }

    let(:round_1) {
      <<~EOT
      #.##.##.##
      #######.##
      #.#.#..#..
      ####.##.##
      #.##.##.##
      #.#####.##
      ..#.#.....
      ##########
      #.######.#
      #.#####.##
      EOT
    }

    let(:round_2) {
      <<~EOT
      #.LL.L#.##
      #LLLLLL.L#
      L.L.L..L..
      #LLL.LL.L#
      #.LL.LL.LL
      #.LLLL#.##
      ..L.L.....
      #LLLLLLLL#
      #.LLLLLL.L
      #.#LLLL.##
      EOT
    }

    let(:round_3) {
      <<~EOT
      #.##.L#.##
      #L###LL.L#
      L.#.#..#..
      #L##.##.L#
      #.##.LL.LL
      #.###L#.##
      ..#.#.....
      #L######L#
      #.LL###L.L
      #.#L###.##
      EOT
    }

    let(:round_4) {
      <<~EOT
      #.#L.L#.##
      #LLL#LL.L#
      L.L.L..#..
      #LLL.##.L#
      #.LL.LL.LL
      #.LL#L#.##
      ..L.L.....
      #L#LLLL#L#
      #.LLLLLL.L
      #.#L#L#.##
      EOT
    }

    let(:round_final) {
      <<~EOT
      #.#L.L#.##
      #LLL#LL.L#
      L.#.L..#..
      #L##.##.L#
      #.#L.LL.LL
      #.#L#L#.##
      ..L.L.....
      #L#L##L#L#
      #.LLLLLL.L
      #.#L#L#.##
      EOT
    }

    it "can render a seat map" do
      max_rows = data.each_line.to_a.length - 1
      max_cols = data.each_line.first.chomp.length - 1
      expect(Seat.render(seat_map, max_rows, max_cols)).to eq(data.chomp)
    end

    it "can transform the seat map according to the rules" do
      rounds = [round_1, round_2, round_3, round_4, round_final].each

      Seat.solution(seat_map) do |new_seat_map, count|
        expect(new_seat_map).to eq(Seat.build_map(rounds.next))
      end
    end

    it "stops, eventually" do
      fin = Seat.solution(seat_map)

      expect(fin).to eq(Seat.build_map(round_final))

      expect(fin.values.filter(&:occupied?).length).to eq(37)
    end    
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_11.txt", __FILE__)) }
    let(:seat_map) { Seat.build_map(data) }

    it "has a solution", slow: true do
      fin = Seat.solution(seat_map)

      expect(fin.values.filter(&:occupied?).length).to eq(2_406)      
    end
  end

  context "second sample data set" do
    it "line of sight seating case #1" do
      data = <<~EOT
        .......#.
        ...#.....
        .#.......
        .........
        ..#L....#
        ....#....
        .........
        #........
        ...#.....
        EOT
      seat_map = Seat.build_map(data) 
  
      seat = seat_map[[4,3]]
      expect(seat).to be_empty

      # $stderr.puts seat_map.filter {|address, seat| !seat.floor?}.keys.reject{|addr| addr == [4,3]}.inspect
      expect(seat.line_of_sight(seat_map)).to match_array([[0, 7], [1, 3], [2, 1], [4, 2], [4, 8], [5, 4], [7, 0], [8, 3]])
    end

    it "line of sight seating case #2" do
      data = <<~EOT
        .............
        .L.L.#.#.#.#.
        .............
        EOT
      seat_map = Seat.build_map(data) 
  
      seat = seat_map[[1,1]]
      expect(seat).to be_empty

      expect(seat.line_of_sight(seat_map)).to match_array([[1, 3]])
    end

    it "line of sight seating case #3" do
      data = <<~EOT
        .##.##.
        #.#.#.#
        ##...##
        ...L...
        ##...##
        #.#.#.#
        .##.##.
        EOT
      seat_map = Seat.build_map(data) 
  
      seat = seat_map[[3,3]]
      expect(seat).to be_empty

      expect(seat.line_of_sight(seat_map)).to match_array([])
    end

    let(:data) {
      <<~EOT
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
      EOT
    }

    let(:round_1) {
      <<~EOT
      #.##.##.##
      #######.##
      #.#.#..#..
      ####.##.##
      #.##.##.##
      #.#####.##
      ..#.#.....
      ##########
      #.######.#
      #.#####.##
      EOT
    }

    let(:round_2) {
      <<~EOT
      #.LL.LL.L#
      #LLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLL#
      #.LLLLLL.L
      #.LLLLL.L#
      EOT
    }

    let(:round_3) {
      <<~EOT
      #.L#.##.L#
      #L#####.LL
      L.#.#..#..
      ##L#.##.##
      #.##.#L.##
      #.#####.#L
      ..#.#.....
      LLL####LL#
      #.L#####.L
      #.L####.L#
      EOT
    }

    let(:round_4) {
      <<~EOT
      #.L#.L#.L#
      #LLLLLL.LL
      L.L.L..#..
      ##LL.LL.L#
      L.LL.LL.L#
      #.LLLLL.LL
      ..L.L.....
      LLLLLLLLL#
      #.LLLLL#.L
      #.L#LL#.L#
      EOT
    }

    it "can transform the seat map according to the rules" do
      seat_map = Seat.build_map(data)

      rounds = [round_1, round_2, round_3, round_4].each

      Seat.solution(seat_map, rule_set: :rule_set_2) do |new_seat_map, count|
        expect(new_seat_map).to eq(Seat.build_map(rounds.next)), Seat.render(new_seat_map, 9, 9)
      end
    end

  end  

  context "problem data, second part" do
    let(:data) { File.read(File.expand_path("../fixtures/day_11.txt", __FILE__)) }
    let(:seat_map) { Seat.build_map(data) }

    it "has a solution", slow: true do
      fin = Seat.solution(seat_map, rule_set: :rule_set_2)

      expect(fin.values.filter(&:occupied?).length).to eq(2_149)      
    end
  end

end