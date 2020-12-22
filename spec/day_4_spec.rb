class Passport
  FIELDS = %w[byr iyr eyr hgt hcl ecl pid cid].each { |f| attr_reader f.to_sym }
  attr_reader :errors

  def initialize(datum)
    @datum = datum
    attributes = datum.split(/\s+/)
    attributes.each do |attr|
      field, value = attr.split(":")
      fail ArgumentError, field unless FIELDS.include?(field)
      instance_variable_set("@#{field}", value)
    end
    @errors = []
  end

  def add_error(label, valid)
    @errors << label unless valid
    valid
  end

  def invalid?
    !valid?
  end

  def present?
    missing = FIELDS.filter { |f| send(f).nil? }
    add_error "Missing fields: #{missing}", (missing - %w[cid]).empty? 
  end

  def valid?
    present? && FIELDS.each { |f| add_error "#{f}: #{send(f)}", send("#{f}?") }
    errors.empty?
  end

  def byr?
    Range.new(1920, 2002) === byr.to_i
  end

  def iyr?
    Range.new(2010, 2020) === iyr.to_i
  end

  def eyr?
    Range.new(2020, 2030) === eyr.to_i
  end

  def hgt?
    return false unless m = hgt.match(/^(\d+)(cm|in)$/)

    value, units = m.captures
    case units
    when "cm" then Range.new(150, 193) === value.to_i
    when "in" then Range.new(59, 76) === value.to_i
    else fail
    end
  end

  def hcl?
    hcl =~ /^\#[0-9a-f]{6}$/
  end

  EYE_COLORS = %w[amb blu brn gry grn hzl oth].freeze
  def ecl?
    EYE_COLORS.include?(ecl)
  end

  def pid?
    pid =~ /^\d{9}$/
  end

  def cid?
    true
  end
end

class PassportBatch
  def initialize(data)
    @data = data.freeze
  end

  def passports
    Array.new.tap do |array|
      @data.each_line("\n\n") do |line|
        array << Passport.new(line)
      end
    end
  end
end

RSpec.describe Passport do
  let(:data) {
    <<~EOT
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in

    EOT
  }

  let(:passports) { PassportBatch.new(data).passports }

  it { expect(passports.filter(&:valid?).count).to eq(2) }

  it "can parse & validate a datum" do
    passport = Passport.new("ecl:gry pid:860033327 eyr:2020 hcl:#fffffd byr:1937 iyr:2017 cid:147 hgt:183cm")
    expect(passport).to be_valid

    passport = Passport.new("iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884 hcl:#cfa07d byr:1929")
    expect(passport).not_to be_valid
    expect(passport.errors).to eq(['Missing fields: ["hgt"]'])

    passport = Passport.new("hcl:#ae17e1 iyr:2013 eyr:2024 ecl:brn pid:760753108 byr:1931 hgt:179cm")
    expect(passport).to be_valid

    passport = Passport.new("hcl:#cfa07d eyr:2025 pid:166559648 iyr:2011 ecl:brn hgt:59in")
    expect(passport).not_to be_valid
    expect(passport.errors).to eq(['Missing fields: ["byr", "cid"]'])
  end

  context "Please call security on the white courtesy phone" do
    let(:data) {
      <<~EOT
      eyr:1972 cid:100
      hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

      iyr:2019
      hcl:#602927 eyr:1967 hgt:170cm
      ecl:grn pid:012533040 byr:1946

      hcl:dab227 iyr:2012
      ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

      hgt:59cm ecl:zzz
      eyr:2038 hcl:74454a iyr:2023
      pid:3556412378 byr:2007
      EOT
    }

    it { expect(passports).to all(be_invalid) }
  end

  context "Please call security on the blue courtesy phone" do
    let(:data) {
      <<~EOT
      pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
      hcl:#623a2f
      
      eyr:2029 ecl:blu cid:129 byr:1989
      iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
      
      hcl:#888785
      hgt:164cm byr:2001 iyr:2015 cid:88
      pid:545766238 ecl:hzl
      eyr:2022
      
      iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
      EOT
    }

    it { expect(passports).to all(be_valid) }
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_4.txt", __FILE__)) }

    it "part1" do
      expect(passports.filter(&:present?).count).to eq(219)
    end 

    it "part2" do
      expect(passports.filter(&:valid?).count).to eq(127)
    end
  end
end