#!/usr/bin/env ruby
require 'rubygems'

# $:.unshift File.dirname(__FILE__)+'/../lib'

require 'args_parser'

parser = ArgsParser.parse ARGV do
  arg :help, :alias => :h, :note => 'show help', :default => false
  arg :input, :alias => :i, :note => 'input file'
  arg :output, :alias => :o, :note => 'output file', :default => 'out.txt'
  arg :interval, :note => 'loop interval', :default => 1
end

p parser
puts parser[:output]
