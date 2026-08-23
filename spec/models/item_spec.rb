# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id          :bigint           not null, primary key
#  category    :string
#  description :string
#  image_url   :string
#  name        :string
#  price       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '#owned_by?' do
    let(:user) { FactoryBot.create(:user, role: 'subscriber') }
    let(:other_user) { FactoryBot.create(:user, role: 'subscriber') }
    let(:item) { FactoryBot.create(:pot_item) }

    context 'when the user owns the item' do
      before do
        FactoryBot.create(:user_item, user: user, item: item)
      end

      it 'returns true' do
        expect(item.owned_by?(user)).to be true
      end
    end

    context 'when the user does not own the item' do
      before do
        FactoryBot.create(:user_item, user: other_user, item: item)
      end

      it 'returns false' do
        expect(item.owned_by?(user)).to be false
      end
    end
  end
end
