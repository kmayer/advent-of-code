require "bag_policy"

RSpec.describe BagPolicy do
  context "sample data - 1" do
    before(:each) do
      data = <<~EOT
      light red bags contain 1 bright white bag, 2 muted yellow bags.
      dark orange bags contain 3 bright white bags, 4 muted yellow bags.
      bright white bags contain 1 shiny gold bag.
      muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
      shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
      dark olive bags contain 3 faded blue bags, 4 dotted black bags.
      vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
      faded blue bags contain no other bags.
      dotted black bags contain no other bags.
      EOT

      BagPolicy.load(data)
    end

    it { 
      expect(BagPolicy.all.select {|policy| policy.contains?("shiny gold")}.map(&:color_code))
      .to match_array([
        "bright white",
        "muted yellow",
        "dark orange",
        "light red",
      ])}
  end

  context "problem data" do
    before(:each) do
      data = File.read(File.expand_path("../fixtures/day_7.txt", __FILE__))
      BagPolicy.load(data)
    end

    it { expect(BagPolicy.all.select{|p| p.contains?("shiny gold")}.count).to eq(229) }
    it { expect(BagPolicy.find("shiny gold").bags.count).to eq(6683) }
  end

  context "sample data - 2" do
    before(:each) do
      data = <<~EOT
      shiny gold bags contain 2 dark red bags.
      dark red bags contain 2 dark orange bags.
      dark orange bags contain 2 dark yellow bags.
      dark yellow bags contain 2 dark green bags.
      dark green bags contain 2 dark blue bags.
      dark blue bags contain 2 dark violet bags.
      dark violet bags contain no other bags.
      EOT

      BagPolicy.load(data)
    end

    it { expect(BagPolicy.find("shiny gold").bags.count).to eq(126) }
  end

end