# frozen_string_literal: true

# Helper method(s) for managing social media share buttons
module SocialMediaHelper
  DEMO_SITE_URL = 'https://team01.demo1.genesys.shefcompsci.org.uk/'

  def share_message
    'Check out Productiv - the ultimate student productivity app!'
  end

  def twitter_share_url(url, text)
    "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}&url=#{CGI.escape(url)}"
  end

  def whatsapp_share_url(url, share_message)
    "https://wa.me/?text=#{CGI.escape("#{share_message}\n\n#{url}")}"
  end

  def reddit_share_url(url, share_message)
    "https://www.reddit.com/submit?kind=link&title=#{CGI.escape(share_message)}&url=#{CGI.escape(url)}"
  end

  def email_share_url(url, share_message)
    "https://mail.google.com/mail/?view=cm&fs=1&su=#{CGI.escape(share_message)}&body=#{CGI.escape("#{share_message}\n\n#{url}")}"
  end
end
