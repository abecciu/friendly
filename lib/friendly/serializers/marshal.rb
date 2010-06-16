
class MarshalSerializer
  def self.generate(obj)
    Marshal.dump(obj)
  end

  def self.parse(obj)
    Marshal.load(obj)
  end
end

Friendly.serializer = MarshalSerializer
