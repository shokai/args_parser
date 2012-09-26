
module ArgsParser
  class Parser

    def parse_style_equal(argv)
      is_option = /^-+([^-=\s]+)$/
      is_param = /^-+([^-=\s]+)=([^=\s]+)$/
      argv.each_with_index do |arg, i|
        if arg =~ is_option
          k,v = [arg.scan(is_option)[0][0], true]
        elsif arg =~ is_param
          k,v = arg.scan(is_param)[0]
        else
          self.argv.push arg
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
