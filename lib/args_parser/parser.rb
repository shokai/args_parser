
module ArgsParser
  def self.parse(argv=[], config={}, &block)
    Config.default.each do |k,v|
      config[k] = v unless config[k]
    end
    parser = Parser.new(config, &block)
    parser.parse argv
    parser
  end

  class Parser
    attr_reader :argv, :params, :aliases

    public
    def first
      argv.first
    end

    def initialize(config, &block)
      unless block_given?
        raise ArgumentError, 'initialize block was not given'
      end
      @config = config
      @argv = []
      @params = Hash.new{|h,k|
        h[k] = {
          :default => nil,
          :description => nil,
          :value => nil,
          :alias => nil,
          :index => -1
        }
      }
      @aliases = {}
      @filter = Filter.new
      @validator = Validator.new
      instance_eval(&block)
      filter do |v|
        (v.kind_of? String and v =~ /^\d+$/) ? v.to_i : v
      end
      filter do |v|
        (v.kind_of? String and v =~ /^\d+\.\d+$/) ? v.to_f : v
      end
    end

    def arg(name, description, opts={})
      params[name][:default] = opts[:default]
      params[name][:description] = description
      params[name][:index] = params.keys.size
      params[name][:alias] = opts[:alias]
      aliases[opts[:alias]] = name if opts[:alias]
    end

    def filter(name=nil, &block)
      if block_given?
        @filter.add name, block
      end
    end

    def on_filter_error(err=nil, name=nil, value=nil, &block)
      if block_given?
        @on_filter_error = block
      else
        @on_filter_error.call(err, name, value)
      end
    end

    def validate(name, message, &block)
      if block_given?
        @validator.add name, message, block
      end
    end

    def args
      params.keys
    end

    def parse(argv)
      method("parse_style_#{@config[:style]}".to_sym).call(argv)
      params.each do |name, param|
        next if [nil, true].include? param[:value]
        begin
          param[:value] = @filter.filter name, param[:value]
        rescue => e
          on_filter_error e, name, param[:value]
        end
        msg = @validator.validate name, param[:value]
        if msg
          STDERR.puts "Error: #{msg} (--#{name} #{param[:value]})"
          exit 1
        end
      end
    end

    def [](key)
      params[key][:value] || params[key][:default]
    end

    def []=(key, value)
      params[key][:value] = value
    end

    def has_option?(*opt)
      !(opt.flatten.map{|i|
          self[i] == true
        }.include? false)
    end

    def has_param?(*param_)
      !(param_.flatten.map{|i|
          v = self[i]
          (v and [String, Fixnum, Float].include? v.class) ? true : false
        }.include? false)
    end

    def inspect
      h = Hash.new
      params.each do |k,v|
        h[k] = v[:value]
      end
      h.inspect
    end

    def help
      params_ = Array.new
      params.each do |k,v|
        v[:name] = k
        params_ << v
      end
      params_ = params_.delete_if{|i|
        i[:index] < 0
      }.sort{|a,b|
        a[:index] <=> b[:index]
      }

      len = params_.map{|i|
        line = " -#{i[:name]}"
        line += " (-#{i[:alias]})" if i[:alias]
        line.size
      }.max

      "options:\n" + params_.map{|i|
        line = " -#{i[:name]}"
        line += " (-#{i[:alias]})" if i[:alias]
        line = line.ljust(len+2)
        line += i[:description].to_s
        line += " : default - #{i[:default]}" if i[:default]
        line
      }.join("\n")
    end

  end
end
