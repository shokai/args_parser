$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'args_parser/parser'
require 'args_parser/filter'
require 'args_parser/validator'

module ArgsParser
  VERSION = '0.0.5'
end
