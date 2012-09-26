
module ArgsParser
  class Parser

    def parse_style_default(argv)
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
            params[k][:value] = arg
            k = nil
          end
        end
      end
      if k
        params[k][:value] = true
      end
    end

  end
end
