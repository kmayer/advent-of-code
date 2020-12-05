require "boarding_pass"

RSpec.describe BoardingPass do
  [
    # code, row, col, ID
    ["FBFBBFFRLR", 44, 5, 357],
    ["BFFFBBFRRR", 70, 7, 567],
    ["FFFBBBFRRR", 14, 7, 119],
    ["BBFFBBFRLL", 102, 4, 820],
  ].each do |(code, row, col, id)|
    it "can decode #{code}" do
      boarding_pass = described_class.new(code)
      expect(boarding_pass.row).to eq(row)
      expect(boarding_pass.col).to eq(col)
      expect(boarding_pass.id).to eq(id)
    end
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_5.txt", __FILE__)) }
    let(:boarding_passes) { 
      Array.new.tap do |array|
        data.each_line do |line|
          array << described_class.new(line)
        end
      end
    }

    it { expect(boarding_passes.map(&:id).max).to eq(989) }
    it "fasten your seat belts" do
      # The missing id is "548"
      expect(boarding_passes.map(&:id).sort.each_cons(2).find {|s0,s1| s1 - s0 > 1}).to eq([547,549])
    end
  end
end