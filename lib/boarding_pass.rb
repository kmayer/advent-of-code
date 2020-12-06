class BoardingPass
  attr_reader :data
  def initialize(pass_code)
    @data = pass_code.freeze
  end

  def id
    data.tr("FBLR", "0101").to_i(2)
  end
end