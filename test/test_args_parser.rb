require File.dirname(__FILE__) + '/test_helper.rb'

class TestArgsParser < Test::Unit::TestCase
  def setup
    @argv = 'test --input ~/tmp -a --o ./out -h'.split(/\s+/)
    @parser = ArgsParser.parse @argv do
      arg :input, :alias => :i, :note => 'input dir'
      arg :output, :alias => :o, :note => 'output dir'
      arg :help, :alias => :h, :note => 'show help'
    end
  end

  def test_first
    assert @parser.first == 'test'
  end

  def test_arg
    assert @parser[:input] == '~/tmp'
  end

  def test_alias
    assert @parser[:output] == './out'
  end

  def test_missing_arg
    assert @parser[:a] == true
  end

  def test_switch
    assert @parser[:help] == true
  end

  def test_has_param?
    assert (@parser.has_param? :input and @parser.has_param? :output)
  end

  def test_has_params?
    assert @parser.has_param? :input, :output
  end

  def test_has_not_param?
    assert !@parser.has_param?(:a)
  end

  def test_has_option?
    assert (@parser.has_option? :help and @parser.has_option? :a)
  end

  def test_has_options?
    assert @parser.has_option? :help, :a
  end

  def test_has_not_option?
    assert !@parser.has_option?(:b)
  end
end
