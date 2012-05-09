
module ArgsParser
  def self.parse(argv=[], &block)
    Parser.new(argv, &block)
  end

  class Parser
    def initialize(argv=[], &block)
      unless block_given?
        raise ArgumentError, 'initialize block was not given'
      end
      instance_eval &block
      parse argv
    end

    def arg(name, opts={})
      params[name][:description] = opts[:description]
      params[name][:value] = opts[:default] unless params[name][:value]
      aliases[opts[:alias]] = name if opts[:alias]
    end

    def args
      params.keys
    end

    def parse(argv)
      k = nil
      argv.each do |arg|
        unless k
          if arg =~ /^-+[^-\s]+$/
            k = arg.scan(/^-+([^-\s]+)$/)[0][0].strip.to_sym
            k = aliases[k]  if aliases[k]
          end
        else
          if arg =~ /^-+[^-\s]+$/
            params[k][:value] = true
            k = arg.scan(/^-+([^-\s]+)$/)[0][0].strip.to_sym
            k = aliases[k]  if aliases[k]
          else
            params[k][:value] = arg
            k = nil
          end
        end
      end
    end

    def [](key)
      params[key][:value]
    end

    def []=(key, value)
      params[key][:value] = value
    end

    def inspect
      h = Hash.new
      params.each do |k,v|
        h[k] = v[:value]
      end
      h.inspect
    end

    private
    def params
      @params ||= Hash.new{|h,k| h[k] = {:description => nil, :value => nil}}
    end

    def aliases
      @aliases ||= Hash.new
    end

  end
end
