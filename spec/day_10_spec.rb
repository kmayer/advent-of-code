require "joltage_adapter"

RSpec.describe JoltageAdapter do
  let(:data) {
    <<~EOT
    16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4
    EOT
  }

  let(:adapters) { data.each_line.map(&:to_i) }

  let(:device_adapter) { adapters.max + 3 }
  it { expect(device_adapter).to eq(22) }

  let(:outlet_joltage) { 0 }
  let(:adapter_chain) { described_class.chain(outlet_joltage, adapters, device_adapter)}
  it { expect(adapter_chain).to eq([outlet_joltage, 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, device_adapter]) }

  let(:chain_distribution) { described_class.chain_distribution(adapter_chain) }

  it { expect(chain_distribution).to eq({1 => 7, 3 => 5})}

  it { expect(described_class.chains(adapter_chain)).to eq(8) }

  context "larger sample set" do
    let(:data) {
      <<~EOT
      28
      33
      18
      42
      31
      14
      46
      20
      48
      47
      24
      23
      49
      45
      19
      38
      39
      11
      1
      32
      25
      35
      8
      17
      7
      9
      4
      2
      34
      10
      3
      EOT
    }

    it { expect(chain_distribution).to eq({1 => 22, 3 => 10}) }
    it { expect(chain_distribution[1] * chain_distribution[3]).to eq(220) }
    it { expect(described_class.chains(adapter_chain)).to eq(19_208) }
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_10.txt", __FILE__)) }
    it { expect(chain_distribution).to eq({1 => 70, 3 => 27}) }
    it { expect(chain_distribution[1] * chain_distribution[3]).to eq(1_890) }
    it { expect(described_class.chains(adapter_chain)).to eq(49_607_173_328_384) }
  end
end