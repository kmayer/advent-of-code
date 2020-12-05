class Passport
  FIELDS = %w[byr iyr eyr hgt hcl ecl pid cid]
  attr_reader *FIELDS
  attr_reader :errors

  def initialize(datum)
    @datum = datum
    attributes = datum.split(/\s+/)
    attributes.each do |attr|
      field, value = attr.split(":")
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
    present? && FIELDS.each { |f| add_error f, send("#{f}?") }
    errors.empty?
  end

  def byr?
    1920 <= byr.to_i && byr.to_i <= 2002
  end

  def iyr?
    2010 <= iyr.to_i && iyr.to_i <= 2020
  end

  def eyr?
    2020 <= eyr.to_i && eyr.to_i <= 2030
  end

  def hgt?
    return false unless m = hgt.match(/^(\d+)(cm|in)$/)

    value, units = m.captures
    case units
    when "cm" then 150 <= value.to_i && value.to_i <= 193
    when "in" then 59 <= value.to_i && value.to_i <= 76
    end
  end

  def hcl?
    hcl =~ /^\#[0-9a-f]{6}$/
  end

  EYE_COLORS = %w[amb blu brn gry grn hzl oth].freeze
  def ecl?
    EYE_COLORS.include?(ecl.strip)
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
    @data = data
  end

  def passports
    array = []
    buf = ""

    @data.each_line do |line|
      if line.chomp =~ /^\s*$/
        array << Passport.new(buf)
        buf = ""
      else
        buf << line.chomp << " "
      end
    end

    array << Passport.new(buf) unless buf == ""

    array
  end
end