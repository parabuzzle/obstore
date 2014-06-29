require 'obstore/filestore'

describe ObStore::FileStore do
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

  describe "#initialize(options)" do
    it 'initializes a storage object' do
      s = ObStore::FileStore.new
      expect(s.store.path).to eq("./tmp/obstore.db")
      expect(s.store.ultra_safe).to eq(false)
    end
    it 'sets pstore to be ultra_safe when setting atomic_writes' do
      s = ObStore::FileStore.new(:atomic_writes=>true)
      expect(s.store.ultra_safe).to eq(true)
    end
  end

  describe "#data=(foo)" do
    before(:each) do
      @s = ObStore::FileStore.new
    end

    it 'allows you to set values for keys using the dot operator' do
      @s.data = "foo"
      expect(@s.data.fetch).to eq("foo")
    end

    it 'allows you to set expiry for the value' do
      @s.data = Hash.new, {:expiry=>300}
      expect(@s.data.expiry).to eq(300)
    end

    it 'allows you to pass a metadata hash' do
      @s.data = {:foo=>"bar"}, {:metadata=>{:baz=>"foo"}}
      expect(@s.data.baz).to eq("foo")
    end

    it 'allows you to set expiry and metadata' do
      @s.data = {:foo=>"bar"}, {:expiry=>600, :metadata=>{:baz=>"foo"}}
      expect(@s.data.expiry).to eq(600)
      expect(@s.data.baz).to eq("foo")
    end

    it 'returns nil if the data has expired' do
      @s.data = {:foo=>"bar"}, {:expiry=>-3}
      expect(@s.data).to eq(nil)
    end

    it 'removes the data from the file if the data is stale' do
      @s.data = {:foo=>"bar"}, {:expiry=>-3}
      expect(@s.data).to eq(nil)
      @s.store.transaction do
        expect(@s.store.root?(:data)).to eq(false)
      end
    end

    it 'removes the object from the store when you nil it out' do
      @s.data = "foo"
      expect(@s.data.fetch).to eq("foo")
      @s.data = nil
      @s.store.transaction do
        expect(@s.store.root?(:data)).to eq(false)
      end
    end
  end

  describe "#compact!" do
    before(:each) do
      @s = ObStore::FileStore.new
      @s.data = {:foo=>"bar"}, {:expiry=>-3}
      @s.more_data = {:foo=>"bar"}, {:expiry=>-3}
      @s.keep = {:foo=>"bar"}, {:expiry=>300}
      @s.never = {:foo=>"bar"}
    end

    it 'removes all expired records from the file' do
      @s.store.transaction do
        expect(@s.store.roots.length).to eq(4)
      end
      @s.compact!
      @s.store.transaction do
        expect(@s.store.roots.length).to eq(2)
        expect(@s.store.root?(:keep)).to eq(true)
        expect(@s.store.root?(:never)).to eq(true)
        expect(@s.store.root?(:data)).to eq(false)
      end
    end

  end

end