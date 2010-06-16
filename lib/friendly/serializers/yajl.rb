
require 'yajl'

class YajlSerializer
  def self.generate(obj)
    Yajl::Encoder.encode(obj)
  end

  def self.parse(source)
    Yajl::Parser.new.parse(source)
  end
end

Friendly.serializer = YajlSerializer
