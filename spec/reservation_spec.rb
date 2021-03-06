require_relative "spec_helper"

describe "Reservation" do
  describe "instantiation" do
    before do
      @room = Hotel::Room.new(id: 1)
      @date_range = Hotel::DateRange.new("03-04-2019", "06-04-2019")
      @reservation = Hotel::Reservation.new(
        id: 1,
        date_range: @date_range,
        room: @room,
        price: 200,
      )
    end

    it "is an instance of Reservation" do
      expect(@reservation).must_be_instance_of Hotel::Reservation
    end

    it "is set up for specific attributes and data types" do
      [:id, :date_range, :room, :price, :room_id, :block, :block_id].each do |prop|
        expect(@reservation).must_respond_to prop
      end

      expect(@reservation.id).must_be_kind_of Integer
      expect(@reservation.date_range).must_be_instance_of Hotel::DateRange
      expect(@reservation.room).must_be_instance_of Hotel::Room
      expect(@reservation.price).must_be_kind_of Integer
      expect(@reservation.room_id).must_be_kind_of Integer

      block = @reservation.block
      if block
        expect(block).must_be_instance_of Hotel::Block
        expect(@reservation.block_id).must_be_kind_of Integer
      else
        assert_nil(block)
        assert_nil(@reservation.block_id)
      end
    end

    it "raises error for unavailable room" do
      date_range = Hotel::DateRange.new("03-04-2019", "05-04-2019")

      expect(@room.is_available?(date_range)).must_equal false
      expect {
        Hotel::Reservation.new(
          id: 2,
          date_range: date_range,
          room: @room,
          price: 200,
        )
      }.must_raise ArgumentError
    end

    it "allows reservation ending on start date of another reservation" do
      date_range = Hotel::DateRange.new("01-04-2019", "03-04-2019")
      reservation = Hotel::Reservation.new(
        id: 3,
        date_range: date_range,
        room: @room,
        price: 200,
      )
      expect(@room.reservations.include?(reservation)).must_equal true
    end

    it "allows reservation starting on end date of another reservation" do
      date_range = Hotel::DateRange.new("06-04-2019", "07-04-2019")
      reservation = Hotel::Reservation.new(
        id: 3,
        date_range: date_range,
        room: @room,
        price: 200,
      )
      expect(@room.reservations.include?(reservation)).must_equal true
    end
  end

  describe "total_price method" do
    before do
      @reservation = Hotel::Reservation.new(
        id: 1,
        date_range: Hotel::DateRange.new("03-04-2019", "06-04-2019"),
        room: Hotel::Room.new(id: 1),
        price: 200,
      )
    end

    it "calculates the correct price" do
      expect(@reservation.total_price).must_equal 600
    end
  end

  describe "overlap method" do
    before do
      @reservation = Hotel::Reservation.new(
        id: 1,
        date_range: Hotel::DateRange.new("03-04-2019", "06-04-2019"),
        room: Hotel::Room.new(id: 1),
        price: 200,
      )
    end

    it "detects an overlapping date range" do
      before_range = "02-04-2019"
      start_date = "03-04-2019"
      during_range1 = "04-04-2019"
      during_range2 = "05-04-2019"
      end_date = "06-04-2019"
      after_range = "07-04-2019"

      range1 = Hotel::DateRange.new(before_range, during_range1)
      range2 = Hotel::DateRange.new(before_range, end_date)
      range3 = Hotel::DateRange.new(before_range, after_range)
      range4 = Hotel::DateRange.new(start_date, during_range1)
      range4 = Hotel::DateRange.new(start_date, end_date)
      range5 = range4 = Hotel::DateRange.new(start_date, after_range)
      range6 = Hotel::DateRange.new(during_range1, during_range2)
      range7 = Hotel::DateRange.new(during_range1, end_date)
      range8 = Hotel::DateRange.new(during_range1, after_range)

      ranges = [range1, range2, range3, range4, range5, range6, range7, range8]

      ranges.each do |range|
        expect(@reservation.overlap?(range)).must_equal true
      end
    end

    it "detects an available date" do
      before_range1 = "01-04-2019"
      before_range2 = "02-04-2019"
      start_date = "03-04-2019"
      end_date = "06-04-2019"
      after_range1 = "07-04-2019"
      after_range2 = "08-04-2019"

      range9 = Hotel::DateRange.new(before_range1, before_range2)
      range10 = Hotel::DateRange.new(before_range2, start_date)
      range11 = Hotel::DateRange.new(end_date, after_range1)
      range12 = Hotel::DateRange.new(after_range1, after_range2)

      ranges = [range9, range10, range11, range12]
      ranges.each do |range|
        expect(@reservation.overlap?(range)).must_equal false
      end
    end
  end
end
