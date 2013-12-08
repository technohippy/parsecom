require 'rubygems'
require 'vcr'

RSpec::Matchers.define :have_params do |expected|
  match do |actual|
    expected.to_a.map do |k, v|
      actual.include? "#{k}=#{URI.encode v.to_s}"
    end.inject(true) {|s, v| s && v}
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data("<COOKIE-KEY>") { |i| [i.response.headers['Set-Cookie']].flatten.compact.first }

  def filter_sensitive_header(c, header)
    c.filter_sensitive_data("<#{header}>") do |interaction|
      if v = interaction.request.headers.detect{|k,_| k.casecmp(header) == 0}
        v.last.first
      end
    end
  end

  filter_sensitive_header(c, 'X-Parse-Application-Id')
  filter_sensitive_header(c, 'X-Parse-Rest-Api-Key')
  filter_sensitive_header(c, 'X-Parse-REST-API-Key')
  filter_sensitive_header(c, 'X-Parse-Master-Key')
  filter_sensitive_header(c, 'X-Parse-Session-Token')
end

ENV['PARSE_APPLICATION_ID'] ||= 'dummy_app_id'
ENV['PARSE_API_KEY'] ||= 'dummy_api_key'
ENV['PARSE_MASTER_KEY'] ||= 'dummy_master_key'

require 'parsecom'
