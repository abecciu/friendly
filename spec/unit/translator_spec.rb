require File.expand_path("../../spec_helper", __FILE__)
require 'ostruct'

describe "Friendly::Translator" do
  before do
    @serializer = stub
    @time       = stub
    @translator = Friendly::Translator.new(@serializer, @time)
  end

  describe "translating a row to an object" do
    before do
      @serializer.stubs(:parse).with("THE JSON").returns(:name => "Stewie")
      @time  = Time.new
      @row   = {:added_id   => 12345,
                :created_at => @time,
                :updated_at => @time,
                :attributes => "THE JSON"}
      @doc   = stub
      @klass = stub
      @klass.stubs(:new_without_change_tracking).
              with(:updated_at => @time,    :new_record => false, 
                   :name       => "Stewie", :created_at => @time).returns(@doc)
    end

    it "creates a new object without change tracking" do
      @translator.to_object(@klass, @row).should == @doc
    end
  end

  describe "translating from a document in to a record" do
    describe "when the document has yet to be saved" do
      before do
        @hash = {:name => "Stewie"}
        @time.stubs(:new).returns(Time.new)
        @serializer.stubs(:generate).with(@hash).returns("SOME JSON")
        @document = stub(:to_serializable     => @hash, 
                         :new_record? => true, 
                         :created_at  => nil,
                         :id          => 12345)
        @record = @translator.to_record(@document)
      end

      it "serializes the attributes" do
        @record[:attributes].should == "SOME JSON"
      end

      it "sets updated_at" do
        @record[:updated_at].should == @time.new
      end

      it "sets the id from the document" do
        @record[:id].should == 12345
      end
    end

    describe "when the document has already been saved" do
      before do
        @created_at = Time.new
        @hash = {:name       => "Stewie",
                 :id         => 1,
                 :created_at => @created_at,
                 :updated_at => Time.new}
        @time.stubs(:new).returns(Time.new + 5000)
        @serializer.stubs(:generate).returns("SOME JSON")
        @document = stub(:to_serializable => @hash,
                         :created_at  => @created_at,
                         :new_record? => false,
                         :id          => 12345)
        @record = @translator.to_record(@document)
      end

      it "serializes the attributes" do
        @serializer.should have_received(:generate).with(:name => "Stewie")
        @record[:attributes].should == "SOME JSON"
      end

      it "doesn't bump the created_at" do
        @record[:created_at].should == @created_at
      end

      it "should bump the updated_at" do
        @record[:updated_at].should == @time.new
      end

      it "takes the id from the documetn" do
        @record[:id].should == 12345
      end
    end
  end
end
