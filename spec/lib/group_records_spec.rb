# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupRecords do
  describe '.group_records_by_time' do
    before do
      date = DateTime.new(2026, 1, 1, 9, 0, 0)

      FactoryBot.create(:user, created_at: date)
      FactoryBot.create(:user, created_at: date + 3.hours)
      FactoryBot.create(:user, created_at: date + 1.day)
      FactoryBot.create(:user, created_at: date + 2.days)
      FactoryBot.create(:user, created_at: date + 2.days + 5.hours)
      FactoryBot.create(:user, created_at: date + 1.week + 1.day)
      FactoryBot.create(:user, created_at: date + 2.months + 1.day)
      FactoryBot.create(:user, created_at: date + 2.months + 2.days)
    end

    context 'with no time range' do
      it 'correctly groups users by hour' do
        expect(described_class.group_records_by_time(User.all, :created_at, nil, :hour)).to eq(
          { '1 Jan 2026 - 9:00' => 1, '1 Jan 2026 - 12:00' => 1, '2 Jan 2026 - 9:00' => 1, '3 Jan 2026 - 9:00' => 1,
            '3 Jan 2026 - 14:00' => 1, '9 Jan 2026 - 9:00' => 1, '2 Mar 2026 - 9:00' => 1, '3 Mar 2026 - 9:00' => 1 }
        )
      end

      it 'correctly groups users by day' do
        expect(described_class.group_records_by_time(User.all, :created_at, nil, :day)).to eq(
          { '1 January 2026' => 2, '2 January 2026' => 1, '3 January 2026' => 2, '9 January 2026' => 1,
            '2 March 2026' => 1, '3 March 2026' => 1 }
        )
      end

      it 'correctly groups users by week' do
        expect(described_class.group_records_by_time(User.all, :created_at, nil, :week)).to eq(
          { '29 Dec 2025 - 4 Jan 2026' => 5, '5 Jan 2026 - 11 Jan 2026' => 1, '2 Mar 2026 - 8 Mar 2026' => 2 }
        )
      end

      it 'correctly groups users by month' do
        expect(described_class.group_records_by_time(User.all, :created_at, nil, :month)).to eq(
          { 'January 2026' => 6, 'March 2026' => 2 }
        )
      end
    end

    context 'with a time range' do
      let(:time_range) { DateTime.new(2026, 1, 6, 9, 0, 0) }

      it 'correctly groups users by hour' do
        expect(described_class.group_records_by_time(User.all, :created_at, time_range, :hour)).to eq(
          { '9 Jan 2026 - 9:00' => 1, '2 Mar 2026 - 9:00' => 1, '3 Mar 2026 - 9:00' => 1 }
        )
      end

      it 'correctly groups users by day' do
        expect(described_class.group_records_by_time(User.all, :created_at, time_range, :day)).to eq(
          { '9 January 2026' => 1, '2 March 2026' => 1, '3 March 2026' => 1 }
        )
      end

      it 'correctly groups users by week' do
        expect(described_class.group_records_by_time(User.all, :created_at, time_range, :week)).to eq(
          { '5 Jan 2026 - 11 Jan 2026' => 1, '2 Mar 2026 - 8 Mar 2026' => 2 }
        )
      end

      it 'correctly groups users by month' do
        expect(described_class.group_records_by_time(User.all, :created_at, time_range, :month)).to eq(
          { 'January 2026' => 1, 'March 2026' => 2 }
        )
      end
    end
  end

  describe '.transform_date_to_week_range' do
    it 'transforms a day to a valid week range' do
      date = DateTime.new(2026, 1, 1, 9, 0, 0)
      expect(described_class.transform_date_to_week_range(date)).to eq('29 Dec 2025 - 4 Jan 2026')
    end

    it "transforms a leap year's extra day to a valid week range" do
      date = DateTime.new(2024, 2, 29, 9, 0, 0)
      expect(described_class.transform_date_to_week_range(date)).to eq('26 Feb 2024 - 3 Mar 2024')
    end

    it 'returns false for an invalid input to convert' do
      expect(described_class.transform_date_to_week_range('Test String')).to be false
    end
  end
end
