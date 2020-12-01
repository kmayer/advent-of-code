require "spec_helper"
require "expense_report"
require "open-uri"

RSpec.describe ExpenseReport do
  subject(:report) { described_class.new(data.shuffle) }

  context "sample data" do
    let(:data) { [1721, 979, 366, 299, 675, 1456] }
    it { expect(report.sum_to_2020).to eq(Set.new([1721, 299])) }
    it { expect(report.sum_to_2020.inject(&:*)).to eq(514_579) }
  end

  context "problem data" do
    let(:data) { 
      # https://adventofcode.com/2020/day/1/input
      array = []
      File.open(File.expand_path("../fixtures/day_1.txt", __FILE__)) { |f|
        f.each_line {|line| array << line.chomp.to_i }
      }
      array
    }
    it { expect(report.sum_to_2020).to eq(Set.new([249, 1771])) }
    it { expect(report.sum_to_2020.inject(&:*)).to eq(440_979)}
  end
end