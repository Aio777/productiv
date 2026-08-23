# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poro::Reporter do
  let(:user) { create(:user, role: 'reporter') }
  let(:reporter_poro) { described_class.new(user) }

  describe '#dashboard_data' do
    context 'when layout value is correct, it return returns correct graph data' do
      it 'returns nothing when value is invalid' do
        user.layout = 20
        expect { reporter_poro.dashboard_data }.to raise_error(Poro::Reporter::InvalidLayoutValueError)
      end

      it 'returns nothing when value is 0' do
        user.layout = 0
        expect(reporter_poro.dashboard_data).to eq([])
      end

      it 'returns one set of graph data with valid value' do
        user.layout = 1
        expect(reporter_poro.dashboard_data.size).to eq(1)
      end

      it 'returns multiple sets of graph data with valid value' do
        user.layout = 15
        expect(reporter_poro.dashboard_data.size).to eq(4)
      end
    end
  end
end
