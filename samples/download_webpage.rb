#!/usr/bin/env ruby
require 'rubygems'
require 'args_parser'
## require File.dirname(__FILE__)+'/../lib/args_parser'

parser = ArgsParser.parse ARGV do
  arg :url, 'URL', :alias => :u
  arg :output, 'output file', :alias => :o, :default => 'out.html'
  arg :verbose, 'verbose mode'
  arg :help, 'show help', :alias => :h
end

if parser.has_option? :help or !parser.has_param?(:url, :output)
  STDERR.puts "Download WebPage\n=="
  STDERR.puts parser.help
  STDERR.puts "e.g.  ruby #{$0} -url http://example.com -o out.html"
  exit 1
end

p parser

require 'open-uri'

puts 'download..' if parser[:verbose]
data = open(parser[:url]).read
puts data if parser[:verbose]

open(parser[:output], 'w+') do |f|
  f.write data
end
puts "saved! => #{parser[:output]}"
