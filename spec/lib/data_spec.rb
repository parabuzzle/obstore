require 'obstore/data'

describe ObStore::Data do
  before(:all) do
    begin
      Dir.mkdir './tmp'
    rescue
    end
  end

  after(:all) do
    begin
      File.delete('./tmp/obstore.db')
    rescue
    end
  end

  describe "#initialize(data=nil, options={})" do
    it 'initalizes an object with nil data' do
      expect(ObStore::Data.new.data).to eq(nil)
    end
    it 'lets you initialize it with a passed in object' do
      expect(ObStore::Data.new(Hash.new).data.class).to eq(Hash)
    end
    it 'sets a nil expiry by default' do
      expect(ObStore::Data.new.expiry).to eq(nil)
    end
    it 'lets you set expiry' do
      expect(ObStore::Data.new(Hash.new, {:expiry=>300}).expiry).to eq(300)
    end
    it 'lets you set any extra metadata you want' do
      expect(ObStore::Data.new(Hash.new, {:metadata=>{:foo=>"bar"}}).foo).to eq("bar")
    end
  end

  describe "#fetch" do
    it 'returns the object we are tracking' do
      expect(ObStore::Data.new(Hash.new).fetch.class).to eq(Hash)
    end
  end

  describe "#save(data)" do
    it 'is a wrapper that sets the data we are tracking' do
      o = ObStore::Data.new(Hash.new)
      expect(o.fetch.class).to eq(Hash)
      o.save "test"
      expect(o.fetch).to eq("test")
    end
  end

  describe "#data=(data)" do
    before(:each) do
      @o = ObStore::Data.new("test")
    end

    it 'sets the data we are tracking' do
      expect(@o.fetch).to eq("test")
      @o.data = "test2"
      expect(@o.fetch).to eq("test2")
    end

    it 'updates the timestamp along with the save' do
      ts = @o.ts
      sleep 1
      @o.data = "test2"
      expect(@o.ts).not_to eq(ts)
    end
  end

  describe "#stale?" do
    before(:each) do
      @o = ObStore::Data.new("test")
    end
    it 'returns false if there is no expiry set' do
      expect(@o.stale?).to eq(false)
    end
    it 'returns false if the data is not stale' do
      @o.expiry = 300
      expect(@o.stale?).to eq(false)
    end
    it 'return true if the data is stale' do
      @o.expiry = 1
      sleep 2
      expect(@o.stale?).to eq(true)
    end
  end

  describe "#data" do
    it 'returns the object we are tracking' do
      expect(ObStore::Data.new("test").data).to eq("test")
    end
  end

  describe "#ts" do
    it 'returns the int version of the timestamp' do
      expect(ObStore::Data.new("test").ts.class).to eq(Fixnum)
    end
  end


end