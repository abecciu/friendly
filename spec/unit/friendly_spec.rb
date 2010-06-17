require File.expand_path("../../spec_helper", __FILE__)

describe "Friendly" do
  describe "configuring friendly" do
    before do
      @datastore = stub
      Friendly::DataStore.stubs(:new).returns(@datastore)
      @db = stub(:meta_def => nil)
      Sequel.stubs(:connect).returns(@db)
      Friendly.configure(:host => "localhost")
    end

    it "creates a db object by delegating to Sequel" do
      Sequel.should have_received(:connect).with(:host => "localhost")
    end

    it "creates a datastore object with the db object" do
      Friendly::DataStore.should have_received(:new).with(@db)
    end

    it "sets the datastore as the default" do
      Friendly.datastore.should == @datastore
    end

    it "loads json serializer if none set" do
      Friendly.serializer.name.should == "JSON"
    end

    it "loads built-in serializer when string is specified" do
      Friendly.configure(:host => "localhost", :serializer => "marshal")
      Friendly.serializer.name.should == "MarshalSerializer"
    end

    it "loads built-in serializer when symbol is specified" do
      Friendly.configure(:host => "localhost", :serializer => :marshal)
      Friendly.serializer.name.should == "MarshalSerializer"
    end

    it "raises a useful error if can't find built-in serializer" do
      lambda {
        Friendly.configure(:host => "localhost", :serializer => :nonexistent)
      }.should raise_error(Friendly::BadSerializer)
    end

    it "set object as serializer if it responds to generate and parse" do
      serializer = stub(:generate => nil, :parse => nil)
      Friendly.configure(:host => "localhost", :serializer => serializer)
      Friendly.serializer.should == serializer
    end

    it "raises a useful error if serializer doesn't respond to generate or parse" do
      serializer = stub(:generate => nil, :dump => nil)
      lambda {
        Friendly.configure(:host => "localhost", :serializer => serializer)
      }.should raise_error(Friendly::BadSerializer)
    end

  end
end
