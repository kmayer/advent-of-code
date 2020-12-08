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