class HandheldVM
  attr_accessor :acc, :pc, :halted
  attr_reader :program

  def initialize(program_file)
    @program = program_file.each_line.map { |line| Instruction.build(line) }
    @acc = 0
    @pc = 0
    @halted = true
  end

  def reset
    self.acc = 0
    self.pc = 0
    program.each(&:reset)
  end

  def inspect
    code = program.map(&:inspect)
    code[pc] = "<#{code[pc]}>" # Highlight the current instruction
    "#<HandheldVM @pc:#{pc} @acc:#{acc} @program:[#{code.join(', ')}]"
  end

  def run
    self.halted = false
    # $stderr.puts "< #{self.inspect}"
    loop do
      fail RuntimeError, pc if pc < 0 # Never happens, but in Ruby, a negative index would do unexpected things
      break if next_instruction.nil?
      break if halted
      if block_given?
        yield self
      else
        next_instruction.exec(self)
      end
      # $stderr.puts "< #{self.inspect}"
    end

    self
  end

  def next_instruction
    program[pc]
  end
end

class Instruction
  attr_reader :arg
  attr_accessor :call_count
  def initialize(argument)
    @arg = argument
    @call_count = 0
  end

  def inspect
    "#{self.class.name.split('::').last.downcase} #{arg} x#{call_count}"
  end

  def exec(vm)
    call(vm)
    self.call_count += 1
  end

  def call(vm)
    raise NotImplementedError, self.class.name
  end

  def reset
    self.call_count = 0
  end

  class << self
    def build(line)
      op, arg = line.chomp.split(/\s+/)
      case op
      when "nop" then Nop.new(arg)
      when "acc" then Acc.new(arg)
      when "jmp" then Jmp.new(arg)
      else
        fail ArgumentError, op
      end
    end
  end
end

class Nop < Instruction
  def call(vm)
    vm.pc += 1
  end
end

class Acc < Instruction
  def call(vm)
    vm.acc += arg.to_i
    vm.pc += 1
  end
end

class Jmp < Instruction
  def call(vm)
    vm.pc += arg.to_i
  end
end
