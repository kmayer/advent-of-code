class PasswordPolicy
  attr_reader :range, :character, :password
  def initialize(passwords_data)
    _range, _character, @password = passwords_data.split(/\s+/)
    @range = Range.new(*_range.split("-").map(&:to_i))
    @character = _character.chop # ":"
  end
end

class SledRentalPasswordPolicy < PasswordPolicy
  def valid?
    char_counts = password.split("").group_by(&:itself)
    range === (char_counts.fetch(character, []).count)
  end
end

class TobogganPasswordPolicy < PasswordPolicy
  def valid?
    (password[range.min - 1] == character) ^ (password[range.max - 1] == character)
  end
end

RSpec.describe SledRentalPasswordPolicy do
  let(:passwords) { 
    <<~EOT
      1-3 a: abcde
      1-3 b: cdefg
      2-9 c: ccccccccc
    EOT
  }
  subject(:password_policies) { passwords.each_line.map { |line| described_class.new(line.chomp) } }

  it "returns only valid passwords" do
    expect(password_policies.filter(&:valid?).count).to eq(2)
  end

  it "validates a count range of characters" do
    password_policy = described_class.new("1-3 a: abcde")
    expect(password_policy).to be_valid

    password_policy = described_class.new("1-3 b: cdefg")
    expect(password_policy).not_to be_valid

    password_policy = described_class.new("2-9 c: ccccccccc")
    expect(password_policy).to be_valid
  end

  context "problem data" do
    let(:passwords) { File.read(File.expand_path("../fixtures/day_2.txt", __FILE__))}

    it { expect(password_policies.filter(&:valid?).count).to eq(556)}
  end
end

RSpec.describe TobogganPasswordPolicy do
  let(:passwords) { 
    <<~EOT
      1-3 a: abcde
      1-3 b: cdefg
      2-9 c: ccccccccc
    EOT
  }
  subject(:password_policies) { passwords.each_line.map { |line| described_class.new(line.chomp) } }

  it "returns only valid passwords" do
    expect(password_policies.filter(&:valid?).count).to eq(1)
  end

  it "validates a count range of characters" do
    password_policy = described_class.new("1-3 a: abcde")
    expect(password_policy).to be_valid

    password_policy = described_class.new("1-3 b: cdefg")
    expect(password_policy).not_to be_valid

    password_policy = described_class.new("2-9 c: ccccccccc")
    expect(password_policy).not_to be_valid
  end

  context "problem data" do
    let(:passwords) { File.read(File.expand_path("../fixtures/day_2.txt", __FILE__))}

    it { expect(password_policies.filter(&:valid?).count).to eq(605)}
  end
end