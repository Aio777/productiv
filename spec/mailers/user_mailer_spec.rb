# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#new_user_email' do
    subject(:mail) { described_class.new_user_email(user, temp_password) }

    let(:user) { create(:user, email: 'test@example.com') }
    let(:temp_password) { 'Password@1234' }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Your account has been created - temporary password inside')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'includes the temporary password in the body' do
      expect(mail.body.encoded).to include(temp_password)
    end

    it 'builds an email message' do
      expect(mail.message).to be_a(Mail::Message)
    end
  end
end
