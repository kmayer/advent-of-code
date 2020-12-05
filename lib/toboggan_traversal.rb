# I kept getting rows & cols mixed up.
Position = Struct.new(:col, :row)

class TobogganTraversal
  TREE = "#"
  OPEN = "."

  attr_reader :forrest, :width, :traversal
  def initialize(data, traversal = [3,1]) # x/col/right, y/row/down
    @forrest = data.split("\n")
    @width = @forrest.first.length
    @traversal = Position.new(*traversal)
  end

  def trees
    count = 0
    position = Position.new(0,0)
    loop do
      position = traverse(position)
      break count if forrest[position.row].nil?
      count += 1 if forrest[position.row][position.col] == TREE
    end
  end

  def traverse(position)
    row = position.row + traversal.row
    col = (position.col + traversal.col) % width

    Position.new(col,row)
  end
end