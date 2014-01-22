#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'optparse'

file = 
target =

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: test-modsec-crs-rules.rb [options] --file tests-xss.xml"
  opts.on( '-h', '--help', 'Tool Usage' ) do
    puts opts
    exit
  end
  opts.on( '-t TARGET', '--target TARGET', 'Target Website (hostname or IP address)' ) do |target|
    options[:target] = target
  end
  opts.on( '-f FILE', '--file FILE', "Path to ModSecurity CRS Test XML file(s)" ) do |file|
    options[:file] = file
  end
end
optparse.parse!

if options[:target] == nil
  puts 'Enter Target Website (hostname or IP Address): '
  options[:target] = gets.chomp
  target = options[:target]
else
  target = options[:target]
end

if options[:file] == nil
  puts 'Enter regression testing XML file location: '
  options[:file] = gets.chomp
  file = options[:file]
else
  file = options[:file]
end

def dump_headers(resp)
	resp.header.each_header {|key,value| puts "#{key}: #{value}" }
end

def test_query_string(payload, target, rule_id)
        puts "[ Testing in QUERY_STRING Param ]"
        payload = URI.encode(URI.decode(payload))
	url = URI.parse("http://#{target}/?test=#{payload}")
	req = Net::HTTP::Get.new(url.request_uri)
        req.initialize_http_header({'User-Agent' => "ModSecurity-CRS-Regression-Testing"})
        resp = Net::HTTP.new(url.host, url.port).start do |http|
                http.request(req)
        end
        header = resp['X-WAF-Events']
	if header != nil
                check_result(header, rule_id, resp)
        else
                puts "Result: FAIL - Payload Not Detected.\n\n"
		dump_headers(resp)
		puts ""
        end
end

def test_post_payload(payload, target, rule_id)
	puts "[ Testing in POST Payload Param ]"
	payload = URI.decode(payload)
	url = URI.parse("http://#{target}/")
	http = Net::HTTP.new(url.host, url.port)
	req = Net::HTTP::Post.new(url.request_uri)
	req.initialize_http_header({'User-Agent' => "ModSecurity-CRS-Regression-Testing"})
	req.set_form_data({"test" => "#{payload}"})
	resp = http.request(req)
	header = resp['X-WAF-Events']
	if header != nil
		check_result(header, rule_id, resp)
	else
                puts "Result: FAIL - Payload Not Detected.\n\n"
		dump_headers(resp)
		puts ""
        end
		
end

def test_request_header(payload, target, rule_id)
        puts "[ Testing in Request Header Variable ]"
        payload = URI.encode(URI.decode(payload))
	url = URI.parse("http://#{target}/")
	req = Net::HTTP::Get.new(url.path)
	req.initialize_http_header({'User-Agent' => "ModSecurity-CRS-Regression-Testing"})
	req.add_field("MODSEC-TEST", "#{payload}")

	resp = Net::HTTP.new(url.host, url.port).start do |http|
  		http.request(req)
	end

        header = resp['X-WAF-Events']
        if header != nil
                check_result(header, rule_id, resp)
        else
                puts "Result: FAIL - Payload Not Detected.\n\n"
		dump_headers(resp)
		puts ""
        end

end

def test_cookie(payload, target, rule_id)
        puts "[ Testing in Cookie Variable ]"
        payload = URI.encode(URI.decode(payload))
        url = URI.parse("http://#{target}/")
        req = Net::HTTP::Get.new(url.request_uri)
        req.initialize_http_header({'User-Agent' => "ModSecurity-CRS-Regression-Testing"})
        req.add_field("Cookie", "test=#{payload}")
        resp = Net::HTTP.new(url.host, url.port).start do |http|
                http.request(req)
        end
        header = resp['X-WAF-Events']
        if header != nil
                check_result(header, rule_id, resp)
        else
                puts "Result: FAIL - Payload Not Detected.\n\n"
		dump_headers(resp)
		puts ""
        end

end

def check_result(header, rule_id, resp)
	if filter_match = /(TX:#{rule_id}-OWASP_CRS.*?)[, ]/.match(header)
        	filter_match_text = filter_match[1]
        	puts "Result: SUCCESS - #{filter_match_text}\n\n"
        else
        	puts "Result: FAIL - Payload Not Detected.\n\n"
		dump_headers(resp)
		puts "\n\n"
        end
end

def testPayload(payload, target, rule_id)
	puts "-=[ Testing Payload: #{payload} ]=-"
	test_query_string(payload, target, rule_id)
	test_post_payload(payload, target, rule_id)
	test_request_header(payload, target, rule_id)
	test_cookie(payload, target, rule_id)
end

@doc = Nokogiri::XML(File.open(options[:file]))
@doc.xpath("//rule").each do |item|
	rule_id = item.xpath('id').text
	description = item.xpath('description').text
	puts "---[ Testing ModSecurity CRS Rule ID(#{rule_id}): #{description} ]---\n-----------------------------------------------------"
	item.xpath('test/payloads/payload').each do |payload|
		payload = payload.text
		testPayload(payload, target, rule_id)
	end
	puts "-----------------------------------------------------"
end
