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