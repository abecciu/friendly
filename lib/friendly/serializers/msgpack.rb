
require 'msgpack'

class MsgPackSerializer
  def self.generate(obj)
    MessagePack.pack(obj)
  end

  def self.parse(source)
    MessagePack.unpack(source)
  end
end

Friendly.serializer = MsgPackSerializer
