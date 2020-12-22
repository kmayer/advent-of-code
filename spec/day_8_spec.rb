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

RSpec.describe HandheldVM do
  let(:data) {
    <<~EOT
    nop +0
    acc +1
    jmp +4
    acc +3
    jmp -3
    acc -99
    acc +1
    jmp -4
    acc +6
    EOT
  }

  subject(:vm) { described_class.new(data) }

  it "halts, but does not catch fire" do
    vm.run do |vm|
      vm.next_instruction.exec(vm)
      vm.halted = vm.next_instruction.call_count >= 1
    end
    
    expect(vm.acc).to eq(5)
  end 

  describe "instruction set" do
    it "nop" do
      vm = described_class.new("nop +0")
      vm.run
      expect(vm.pc).to eq(1)
      expect(vm.acc).to eq(0)
    end

    it "acc" do
      vm = described_class.new("acc +1")
      vm.run
      expect(vm.pc).to eq(1)
      expect(vm.acc).to eq(1)
    end

    it "jmp" do
      vm = described_class.new("jmp +10")
      vm.run
      expect(vm.pc).to eq(10) # This runs off the end of the program
      expect(vm.acc).to eq(0)
    end

    it "jmp can't jump before the beginning of the program" do
      vm = described_class.new("jmp -10")
      expect { vm.run }.to raise_error(RuntimeError, "-10")
    end
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_8.txt", __FILE__)) }
    it "would loop forever" do
      vm.run do |running_vm|
        running_vm.next_instruction.exec(running_vm)
        running_vm.halted = running_vm.next_instruction.call_count >= 1
      end

      expect(vm.pc).to eq(439)
      expect(vm.acc).to eq(1_709)
    end

    it "can be fixed" do
      lines = data.each_line.to_a
      expect(lines.length).to eq(617)

      fixed = (0...lines.length).each { |lineno|
        vm.reset

        vm.run do |running_vm|
          if running_vm.pc == lineno
            case instr = running_vm.next_instruction
            when Jmp then running_vm.pc += 1              # Simulate Nop
            when Nop then running_vm.pc += instr.arg.to_i # Simulate Jmp
            else instr.call(running_vm)                   # Just make the call
            end

            instr.call_count += 1
          else
            running_vm.next_instruction.exec(running_vm)
          end

          # Catch infinite loops
          vm.halted = vm.next_instruction && vm.next_instruction.call_count >= 1
        end

        break vm if vm.next_instruction.nil? # properly halted
      }
      
      expect(fixed.acc).to eq(1976)
    end
  end


end