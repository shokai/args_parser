
module ArgsParser
  class Parser

    def parse_style_equal(argv)
      argv.each_with_index do |arg, i|
        if arg =~ /^--+[^-=\s]+$/
          k,v = [arg.scan(/^--+([^-=\s]+)$/)[0][0], true]
        elsif arg =~ /^--+[^-=\s]+=[^=\s]+$/
          k,v = arg.scan(/^--+([^-=\s]+)=([^=\s]+)$/)[0]
        elsif i == 0
          @first = arg
        end
        if k and v
          k = k.strip.to_sym
          k = aliases[k] if aliases[k]
          params[k][:value] = v
        end
      end
    end

  end
end
