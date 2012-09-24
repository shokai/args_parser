
module ArgsParser
  def self.parse(argv=[], &block)
    parser = Parser.new(&block)
    parser.parse argv
    parser
  end

  class Parser
    attr_reader :first

    private
    def params
      @params ||=
        Hash.new{|h,k|
        h[k] = {
          :default => nil,
          :description => nil,
          :value => nil,
          :alias => nil,
          :index => -1
        }
      }
    end

    def aliases
      @aliases ||= Hash.new
    end

    public
    def initialize(&block)
      unless block_given?
        raise ArgumentError, 'initialize block was not given'
      end
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

    def validate(name, message, &block)
      if block_given?
        @validator.add name, message, block
      end
    end

    def args
      params.keys
    end

    def parse(argv)
      k = nil
      argv.each_with_index do |arg, index|
        unless k
          if arg =~ /^-+[^-\s]+$/
            k = arg.scan(/^-+([^-\s]+)$/)[0][0].strip.to_sym
            k = aliases[k]  if aliases[k]
          elsif index == 0
            @first = arg
          end
        else
          if arg =~ /^-+[^-\s]+$/
            params[k][:value] = true
            k = arg.scan(/^-+([^-\s]+)$/)[0][0].strip.to_sym
            k = aliases[k]  if aliases[k]
          else
            arg = @filter.filter k, arg
            msg = @validator.validate k, arg
            if msg
              STDERR.puts "Error: #{msg} (--#{k} #{arg})"
              exit 1
            end
            params[k][:value] = arg
            k = nil
          end
        end
      end
      if k
        params[k][:value] = true
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
