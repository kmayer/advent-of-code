class SledRentalPasswordPolicy
  attr_reader :range, :character, :password
  def initialize(passwords_data)
    range, character, @password = passwords_data.split(/\s+/)
    @range = Range.new(*range.split("-").map(&:to_i))
    @character = character.chop # ":"
  end

  def valid?
    char_counts = password.split("").group_by(&:itself)
    range === (char_counts.fetch(character, []).count)
  end
end

class TobogganPasswordPolicy
  attr_reader :range, :character, :password
  def initialize(passwords_data)
    range, character, @password = passwords_data.split(/\s+/)
    @range = range.split("-").map(&:to_i)
    @character = character.chop # ":"
  end

  def valid?
    (password[range.first - 1] == character) ^ (password[range.last - 1] == character)
  end
end