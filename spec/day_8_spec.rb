require "handheld_vm"

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