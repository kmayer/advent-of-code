class TobogganTraversal
  TREE = "#"
  OPEN = "."

  attr_reader :forrest, :width, :start, :traversal
  def initialize(data, traversal = [3,1]) # row/down, col/right
    @forrest = data.split("\n")
    @width = @forrest.first.length
    @start = start
    @traversal = traversal
  end

  def trees
    count = 0
    position = [0,0]
    loop do
      position = traverse(position)
      break count if forrest[position.first].nil?
      count += 1 if forrest[position.first][position.last] == TREE
    end
  end

  def traverse(position)
    row = position.first + traversal.last
    col = (position.last + traversal.first) % width

    [row, col]
  end
end