
module ArgsParser
  class Filter
    def filters
      @filters ||= []
    end

    def add(name, filter)
      name = name.to_sym if name
      filters.push({:name => name, :filter => filter})
    end

    def filter(name, value)
      filters.each do |f|
        if !f[:name] or f[:name] == name
          value = f[:filter].call(value)
        end
      end
      value
    end
  end
end
