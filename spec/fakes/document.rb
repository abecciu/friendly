class FakeDocument
  attr_accessor :id, :created_at, :to_hash, :new_record, :table_name,
                :indexes, :name, :updated_at

  def initialize(opts = {})
    opts.each { |k,v| send("#{k}=", v) }
  end

  def new_record?
    new_record
  end
end

