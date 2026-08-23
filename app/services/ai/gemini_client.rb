# frozen_string_literal: true

require 'json'
require 'net/http'

class Ai::GeminiClient
  class Error < StandardError; end

  API_BASE = 'https://generativelanguage.googleapis.com'
  DEFAULT_MODEL = 'gemini-2.5-flash'
  PROMPT_PATH = Rails.root.join('config/ai/task_breakdown_prompt.md')

  def self.generate_text(prompt)
    api_key = fetch_api_key!
    model = fetch_model

    uri = build_uri(model: model, api_key: api_key)
    body = build_body(prompt)

    response = post_json(uri, body)
    parsed = safe_parse_json(response.body)

    raise_if_not_success!(response, parsed)

    extract_text(parsed)
  end

  def self.fetch_api_key!
    api_key =
      ENV['GEMINI_API_KEY'].presence ||
      Rails.application.credentials.gemini_api_key

    raise Error, 'Missing GEMINI_API_KEY (set ENV locally or credentials on server)' if api_key.blank?

    api_key
  end
  private_class_method :fetch_api_key!

  def self.fetch_model
    ENV['GEMINI_MODEL'].presence ||
      Rails.application.credentials.dig(:gemini, :model).presence ||
      DEFAULT_MODEL
  end
  private_class_method :fetch_model

  def self.build_uri(model:, api_key:)
    URI("#{API_BASE}/v1beta/models/#{model}:generateContent?key=#{api_key}")
  end
  private_class_method :build_uri

  def self.build_body(prompt)
    final_prompt = "#{system_instruction}\n\nUser task:\n#{prompt}"

    {
      contents: [
        { parts: [{ text: final_prompt }] }
      ]
    }
  end
  private_class_method :build_body

  def self.system_instruction
    @system_instruction ||= File.read(PROMPT_PATH)
  end
  private_class_method :system_instruction

  def self.post_json(uri, body)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = JSON.generate(body)

    http.request(req)
  end
  private_class_method :post_json

  def self.safe_parse_json(str)
    JSON.parse(str)
  rescue JSON::ParserError, TypeError
    {}
  end
  private_class_method :safe_parse_json

  def self.raise_if_not_success!(response, parsed)
    return if response.code.to_i.between?(200, 299)

    msg = parsed['error']&.dig('message') || response.body
    raise Error, "Gemini error (#{response.code}): #{msg}"
  end

  private_class_method :raise_if_not_success!

  def self.extract_text(parsed)
    parsed.dig('candidates', 0, 'content', 'parts', 0, 'text') ||
      '(No text returned by Gemini)'
  end
  private_class_method :extract_text
end
