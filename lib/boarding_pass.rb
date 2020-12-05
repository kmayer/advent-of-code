class BoardingPass
  attr_reader :data
  def initialize(pass_code)
    @data = pass_code.freeze
  end

  def row
    row_string.tr("FB", "01").to_i(2)
  end

  def col
    col_string.tr("LR", "01").to_i(2)
  end

  def id
    row * 8 + col
  end

  private

  def row_string
    data[0..6]
  end

  def col_string
    data[7..-1]
  end
end