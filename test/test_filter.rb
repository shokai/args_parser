require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestArgsParserFilter < MiniTest::Unit::TestCase
  def setup
    @argv = ['--count', '35']
    @@err = nil
    @@name = nil
    @@value = nil
    @parser = ArgsParser.parse @argv do
      arg :count, 'number'

      filter :count do |v|
        raise NoMethodError, 'error!!'
      end

      on_filter_error do |err, name, value|
        @@err = err
        @@name = name
        @@value = value
      end
    end
  end

  def test_filter_error
    assert @@name == :count
    assert @@value == '35'
    assert @@err.class == NoMethodError
  end
end
