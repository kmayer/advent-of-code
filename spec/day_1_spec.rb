require "expense_report"

RSpec.describe ExpenseReport do
  subject(:report) { described_class.new }

  context "sample data" do
    let(:data) { [1721, 979, 366, 299, 675, 1456] }
    it "take(2)" do expect(report.sum_to_2020(data)).to eq([1721, 299]) end
    it { expect(report.sum_to_2020(data).inject(&:*)).to eq(514_579) }
    it "take(3)" do expect(report.sums_to(2020, 3, data)).to eq([979, 366, 675]) end
    it { expect(report.sums_to(2020, 3, data).inject(&:*)).to eq(241861950) }
  end

  context "problem data" do
    let(:data) { @problem_data ||= Array.new.tap { |array|
        # https://adventofcode.com/2020/day/1/input
        File.open(File.expand_path("../fixtures/day_1.txt", __FILE__)) { |f|
          f.each_line {|line| array << line.chomp.to_i }
        }
      }
    }

    it { expect(report.sum_to_2020(data).inject(&:*)).to eq(440_979)}
    it { expect(report.sums_to(2020, 3, data).inject(&:*)).to eq(82_498_112) }
  end
end