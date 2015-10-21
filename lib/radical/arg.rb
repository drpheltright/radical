module Radical
  class Arg < Struct.new(:name)
    def self.[](name)
      new(name)
    end
  end
end
