require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestVersion < MiniTest::Unit::TestCase
  def test_version
    assert ArgsParser::VERSION > '0.0.0'
  end
end
