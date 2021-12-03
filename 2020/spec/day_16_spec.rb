class TicketDecoder
  attr_reader :rules, :ranges
  def initialize(rules)
    @rules = rules
    @ranges = rules.values.flatten

  end

  def valid_tickets(tickets)
    tickets.filter {|ticket| ticket.all? {|field| ranges.any?{|range| range === field}}}
  end

  def field_positions(valid_tickets)
    width = valid_tickets.first.length - 1

    rules.map { |rule, ranges|
      column = 0.upto(width).filter do |i|
        valid_tickets.all? { |ticket|
          ranges.any? { |range| range === ticket[i] }
        }
      end
      [rule, column]
    }
    .sort_by { |k,v| v.length }
  end

  def solve(fields)
    fields.inject({}) { |s, (rule, positions)|
      s[rule] = positions.detect {|pos| !s.values.include?(pos) }
      s
    }
  end
end

RSpec.describe "Ticket Translation" do
  it "given ranges, returns anything that doesn't pass through all of the filters" do
    ranges = [1..3, 5..7, 6..11, 33..44, 13..40, 45..50]

    tickets = [[7,3,47],[40,4,50],[55,2,20],[38,6,12]]

    values = tickets.flat_map do |ticket|
      ticket.reject {|field| ranges.any?{|range| range === field}}
    end

    expect(values).to eq([4,55,12])
  end

  it "given ranges, computes the columns" do
    rules = {
      class: [0..1, 4..19],
      row: [0..5, 8..19],
      seat: [0..13, 16..19],
    }

    tickets = [
      [3,9,18],
      [15,1,5],
      [5,14,9],
    ]

    decoder = TicketDecoder.new(rules)

    expect(valid_tickets = decoder.valid_tickets(tickets)).to eq(tickets)

    fields = decoder.field_positions(valid_tickets)

    expect(fields).to eq([[:seat, [2]], [:class, [1, 2]], [:row, [0, 1, 2]]])

    solution = decoder.solve(fields)

    expect(solution).to eq({:class=>1, :row=>0, :seat=>2})
  end

  context "problem data" do
    let(:data) { File.read(File.expand_path("../fixtures/day_16_nearby_tickets.txt", __FILE__)) }
    let(:rules) do {
        departure_location: [32..174, 190..967],
        departure_station: [50..580, 588..960],
        departure_platform: [35..595, 621..972],
        departure_track: [41..85, 104..962],
        departure_date: [39..293, 299..964],
        departure_time: [44..192, 215..962],
        arrival_location: [46..238, 255..963],
        arrival_station: [44..721, 731..960],
        arrival_platform: [29..826, 846..958],
        arrival_track: [49..525, 543..953],
        class: [43..804, 827..955],
        duration: [48..273, 291..959],
        price: [45..767, 793..967],
        route: [44..300, 311..962],
        row: [25..119, 140..954],
        seat: [38..389, 410..974],
        train: [29..697, 714..968],
        type: [32..55, 65..968],
        wagon: [39..642, 660..955],
        zone: [41..567, 578..959],
      }
    end

    it "solves the problem" do
      decoder = TicketDecoder.new(rules)

      tickets = data.each_line(chomp: true).map {|line| line.split(",").map(&:to_i)}

      values = tickets.flat_map do |ticket|
        ticket.reject { |field| decoder.ranges.any?{ |range| range === field } }
      end
  
      expect(values.sum).to eq(19_240)
    end

    it "solves the second problem" do
      decoder = TicketDecoder.new(rules)

      tickets = data.each_line(chomp: true).map {|line| line.split(",").map(&:to_i)}

      valid_tickets = decoder.valid_tickets(tickets)

      fields = decoder.field_positions(valid_tickets)

      solution = decoder.solve(fields)

      my_ticket = [149,73,71,107,113,151,223,67,163,53,173,167,109,79,191,233,83,227,229,157]

      answer = solution
        .map { |rule, col| rule.to_s =~ /^departure/ && my_ticket[col] }
        .compact
        .inject(&:*)

      expect(answer).to eq(21_095_351_239_483)
    end
  end
end