require File.dirname(__FILE__) + '/test_helper.rb'

class TestArgsParserStyleEqual < Test::Unit::TestCase
  def setup
    @argv = 'test --input=http://shokai.org --a --o=./out -h --depth=-030 foo bar --pi=-3.140 --n=ShoKaI'.split(/\s+/)
    @parser = ArgsParser.parse @argv, :style => :equal do
      arg :input, 'input', :alias => :i
      arg :output, 'output dir', :alias => :o
      arg :name, 'user name', :alias => :n
      arg :help, 'show help', :alias => :h

      filter :name do |v|
        v.downcase
      end

      validate :input, "input must be valid URL" do |v|
        v =~ /^https?:\/\/.+/
      end
    end
  end

  def test_first
    assert @parser.first == 'test'
  end

  def test_argv
    assert @parser.argv == ['test', 'foo', 'bar']
  end

  def test_arg
    assert @parser[:input] == 'http://shokai.org'
  end

  def test_alias
    assert @parser[:output] == './out'
  end

  def test_cast_integer
    assert @parser[:depth] == -30
    assert @parser[:depth].class == Fixnum
  end

  def test_cast_float
    assert @parser[:pi] == -3.14
    assert @parser[:pi].class == Float
  end

  def test_filter
    assert @parser[:name] == 'shokai'
  end

  def test_missing_arg
    assert @parser[:b] != true
  end

  def test_switch
    assert @parser[:help] == true
  end

  def test_has_param?
    assert @parser.has_param? :input
    assert @parser.has_param? :output
    assert @parser.has_param? :depth
    assert @parser.has_param? :pi
    assert @parser.has_param? :name
  end

  def test_has_params?
    assert @parser.has_param? :input, :output, :depth, :pi, :name
  end

  def test_has_not_param?
    assert !@parser.has_param?(:a)
  end

  def test_has_option?
    assert @parser.has_option? :help 
    assert @parser.has_option? :a
  end

  def test_has_options?
    assert @parser.has_option? :help, :a
  end

  def test_has_not_option?
    assert !@parser.has_option?(:b)
  end
end
