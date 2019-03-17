require_relative "spec_helper"
require "pry"

describe "Booker class" do
  describe "initialization" do
    before do
      @booker = Hotel::Booker.new
      @rooms = @booker.rooms
      @reservations = @booker.reservations
    end

    it "rooms is an array of rooms" do
      @rooms.each.with_index(1) do |room, i|
        expect(room).must_be_instance_of Hotel::Room
        expect(room.id).must_equal i
      end
      expect(@rooms).must_be_instance_of Array
      expect(@rooms.count).must_equal 20
    end

    it "reservations is an empty array" do
      expect(@reservations).must_equal []
    end
  end

  describe "reserve method" do
    describe "reservation creation" do
      before do
        @booker = Hotel::Booker.new
        start_date = "03-04-2019"
        end_date = "06-04-2019"
        @reservation = @booker.reserve(
          start_date: start_date,
          end_date: end_date,
        )
        @room = @reservation.room
      end

      it "creates a reservation" do
        expect(@reservation).must_be_instance_of Hotel::Reservation
      end

      it "reservation is in reservations array" do
        expect(@booker.reservations.include?(@reservation)).must_equal true
      end

      it "adds reservation to the room" do
        expect(@room.reservations.include?(@reservation)).must_equal true
      end

      it "reservation ids are unique" do
        booker = Hotel::Booker.new
        20.times do |i|
          reservation = booker.reserve(start_date: "03-04-2019", end_date: "06-04-2019")
          expect(reservation.id).must_equal i + 1
        end
      end
    end

    describe "room availability" do
      before do
        @booker = Hotel::Booker.new
        @start_date = "03-04-2019"
        @end_date = "06-04-2019"
        @date_range = Hotel::DateRange.new(@start_date, @end_date)
        @assigned_room = @booker.open_room(@date_range)
      end

      it "room is available before reservation" do
        expect(@assigned_room.is_available?(@date_range)).must_equal true
      end

      it "room is unavailable after reservation" do
        reservation = @booker.reserve(
          start_date: @start_date,
          end_date: @end_date,
        )
        room = reservation.room
        expect(room).must_equal @assigned_room
        expect(room.is_available?(@date_range)).must_equal false
      end

      it "raises an argument error if no available rooms" do
        booker = Hotel::Booker.new
        expect {
          21.times do
            booker.reserve(start_date: "03-04-2019", end_date: "06-04-2019")
          end
        }.must_raise ArgumentError
      end
    end
  end

  describe "available_rooms" do
    it "correctly returns all avaialable rooms" do
      booker = Hotel::Booker.new
      date_range = Hotel::DateRange.new("03-04-2019", "06-04-2019")
      available_rooms = booker.available_rooms(date_range)
      rooms = booker.rooms

      available_rooms.each do |room|
        expect(rooms.include?(room)).must_equal true
      end
      expect(available_rooms).must_be_instance_of Array
    end

    it "returns an empty array if no rooms available" do
      booker = Hotel::Booker.new
      date_range = Hotel::DateRange.new("03-04-2019", "06-04-2019")
      20.times do
        booker.reserve(start_date: "03-04-2019", end_date: "06-04-2019")
      end
      expect(booker.available_rooms(date_range)).must_equal []
    end
  end

  describe "reservations_by_date" do
    it "correctly returns reservations by date range" do
      booker = Hotel::Booker.new
      date_range = Hotel::DateRange.new("03-04-2019", "06-04-2019")

      reservations = (1..5).map do
        booker.reserve(start_date: "03-04-2019", end_date: "06-04-2019")
      end

      reservations_list = booker.reservations_by_date(date_range)

      reservations.each do |reservation|
        expect(reservations_list.include?(reservation)).must_equal true
      end
    end

    it "returns empty array if there are no reservations" do
      booker = Hotel::Booker.new
      date_range = Hotel::DateRange.new("03-05-2019", "06-05-2019")
      reservations_list = booker.reservations_by_date(date_range)
      expect(reservations_list).must_equal []
    end
  end
end
