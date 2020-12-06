class CustomDeclaration
  attr_reader :group
  def initialize(group)
    @group = group.each_line.map(&:chomp).map(&:chars).reject(&:empty?).map(&:to_set)
  end

  def score
    group.inject(&:|).count # union
  end
end

class CustomDeclaration2 < CustomDeclaration
  def score
    group.inject(&:&).count # intersection
  end
end
