class MemoryGame
  attr_reader :mem
  attr_accessor :turn, :last_number
  def initialize(starting_numbers)
    @mem = (Hash.new { |h,k| h[k] = Array.new }).tap do |h|
      starting_numbers.each.with_index do |n, i|
        @turn = i + 1
        h[n] = [@turn]
      end
    end
    @last_number = starting_numbers.last
  end

  def next
    @turn += 1

    if mem[last_number].count <= 1
      @last_number = 0
    else
      @last_number = mem[last_number].inject(&:-)
    end

    mem[last_number].unshift(turn)
    mem[last_number].pop if mem[last_number].count > 2

    # $stderr.puts "\n\n\nturn: #{turn}: #{last_number}"
    # $stderr.puts mem

    last_number
  end

  def take(n)
    loop do
      self.next
      break last_number if turn == n
    end
  end
end

RSpec.describe "Rambunctious Recitation" do
  it "has a memory for figures" do
    game = MemoryGame.new([0,3,6])

    expect(game.next).to eq(0) # 4
    expect(game.next).to eq(3) # 5
    expect(game.next).to eq(3) # 6
    expect(game.next).to eq(1) # 7
    expect(game.next).to eq(0) # 8
    expect(game.next).to eq(4) # 9
    expect(game.next).to eq(0) # 10
  end

  it "2020" do
    game = MemoryGame.new([0,3,6])
    expect(game.take(2020)).to eq(436)

    game = MemoryGame.new([1,3,2])
    expect(game.take(2020)).to eq(1)

    game = MemoryGame.new([2,1,3])
    expect(game.take(2020)).to eq(10)

    game = MemoryGame.new([1,2,3])
    expect(game.take(2020)).to eq(27)

    game = MemoryGame.new([2,3,1])
    expect(game.take(2020)).to eq(78)

    game = MemoryGame.new([3,2,1])
    expect(game.take(2020)).to eq(438)

    game = MemoryGame.new([3,1,2])
    expect(game.take(2020)).to eq(1836)

    game = MemoryGame.new([9,19,1,6,0,5,4])
    expect(game.take(2020)).to eq(1522)
  end

  it "part 2, slow", slow: true do
    game = MemoryGame.new([0,3,6])
    expect(game.take(30_000_000)).to eq(175_594)    

    game = MemoryGame.new([9,19,1,6,0,5,4])
    expect(game.take(30_000_000)).to eq(18234)
  end
end