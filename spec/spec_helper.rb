require 'rubygems'

RSpec::Matchers.define :have_params do |expected|
  match do |actual|
    expected.to_a.map do |k, v|
      actual.include? "#{k}=#{URI.encode v.to_s}"
    end.inject(true) {|s, v| s || v}
  end
end

require 'parsecom'
# setup Parse object
Parse.credentials application_id: ENV['APPLICATION_ID'], api_key: ENV['API_KEY'], master_key: ENV['MASTER_KEY']
#puts('set your credentials in spec/spec_helper.rb and remove this line') || exit
