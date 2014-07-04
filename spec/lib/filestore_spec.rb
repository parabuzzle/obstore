require 'obstore/filestore'
require './spec/dummy_object'

describe ObStore::FileStore do
  before(:all) do
    begin
      Dir.mkdir './tmp'
    rescue
      # ignored
    end
  end

  after(:all) do
    begin
      File.delete('./tmp/obstore.db')
      File.delete('./tmp/keytest.db')
    rescue
      # ignored
    end
  end

  describe "#initialize(options)" do
    it 'initializes a storage object' do
      s = ObStore::FileStore.new
      expect(s._store.path).to eq("./tmp/obstore.db")
      expect(s._store.ultra_safe).to eq(false)
    end
    it 'sets pstore to be ultra_safe when setting atomic_writes' do
      s = ObStore::FileStore.new(:atomic_writes=>true)
      expect(s._store.ultra_safe).to eq(true)
    end

    it 'allows you to set atomic_writes after you create the object' do
      s = ObStore::FileStore.new
      expect(s._store.ultra_safe).to eq(false)
      s.atomic_writes = true
      expect(s._store.ultra_safe).to eq(true)
    end
  end

  describe "#atomic_writes" do
    it 'returns the ultra_safe status of the internal pstore' do
      s = ObStore::FileStore.new
      expect(s.atomic_writes).to eq(s._store.ultra_safe)
    end

    it 'allows you to set the ultra_safe status of the internal pstore' do
      s = ObStore::FileStore.new
      expect(s._store.ultra_safe).to eq(false)
      s.atomic_writes = true
      expect(s._store.ultra_safe).to eq(true)
    end
  end

  describe "#store" do
    before(:each) do
      @obstore = ObStore::FileStore.new
    end

    it 'allows you to store an object to the pstore db' do
      @obstore.store :data, "some data"
      expect(@obstore.fetch :data).to eq("some data")
    end

    it 'throws a type error if the key is not a symbol' do
      expect{@obstore.store "data", "something"}.to raise_error(TypeError)
    end

    it 'handles any object' do
      ob = DummyObject.new
      ob.data = "foo"
      @obstore.store :dummy, ob
      expect(@obstore.fetch(:dummy).class).to eq(DummyObject)
      expect(@obstore.fetch(:dummy).data).to eq("foo")
    end

    it 'handles persisting data changes to an object' do
      ob = DummyObject.new
      ob.data = "foo"
      @obstore.store :dummy, ob
      expect(@obstore.fetch(:dummy).class).to eq(DummyObject)
      expect(@obstore.fetch(:dummy).data).to eq("foo")
      ob.data = "bar"
      @obstore.store :dummy, ob
      expect(@obstore.fetch(:dummy).data).to eq("bar")
    end

    it 'handles setting expiry' do
      @obstore.store :data, "foo", {:expiry=>300}
      expect(@obstore.data.expiry).to eq(300)
    end
  end

  describe '#fetch(key)' do
    before(:each) do
      @obstore = ObStore::FileStore.new
    end

    it 'fetches the tracked object for the key' do
      @obstore.store :data, "foo"
      expect(@obstore.fetch :data).to eq("foo")
    end

    it 'fetches the actual tracked object instance' do
      ob = DummyObject.new
      ob.data = "bar"
      @obstore.store :dummy, ob
      expect(@obstore.fetch(:dummy).class).to eq(DummyObject)
      expect(@obstore.fetch(:dummy).data).to eq("bar")
    end
  end

  describe '#keys' do
    it 'returns all the keys we have saved' do
      @obstore = ObStore::FileStore.new(:database=>'./tmp/keytest.db')
      expect(@obstore.keys).to eq([])
      @obstore.store(:data, "foo")
      expect(@obstore.keys.include?(:data)).to eq(true)
    end
  end

  describe '#data' do
    before(:each) do
      @obstore = ObStore::FileStore.new
    end

    it 'fetches the ObStore::Data object' do
      @obstore.store :data, "foo"
      expect(@obstore.data.class).to eq(ObStore::Data)
    end

    it 'allows me to pass in an ObStore::Data object directly to be saved' do
      @obstore.data = ObStore::Data.new("foo")
      expect(@obstore.data.fetch).to eq("foo")
    end

    it 'allows me to nil a key out directly' do
      @obstore.data = ObStore::Data.new("foo")
      expect(@obstore.data.fetch).to eq("foo")
      @obstore.data = nil
      expect(@obstore.fetch :data).to eq(nil)
    end

    it 'throws a TypeError if passed anything other than ObStore::Data object' do
      expect{@obstore.data = "foo"}.to raise_error(TypeError)
    end

    # TODO: persist metadata changes on update
    #it 'persists metadata changes on update' do
    #  @obstore.store :data, {:foo=>"bar"}, {:expiry=>400, :metadata=>{:foo=>"bar"}}
    #  expect(@obstore.data.foo).to eq("bar")
    #  @obstore.data.foo = "baz"
    #  expect(@obstore.data.foo).to eq("baz")
    #  @obstore.data.expiry = 500
    #  expect(@obstore.data.expiry).to eq(500)
    #end
  end

  describe "#compact!" do
    before(:each) do
      begin
        File.delete('./tmp/obstore.db')
        File.delete('./tmp/keytest.db')
      rescue
        # ignored
      end
      begin
        Dir.mkdir './tmp'
      rescue
        # ignored
      end
      @obstore = ObStore::FileStore.new
      @obstore.store :data, {:foo=>"bar"}, {:expiry=>-3}
      @obstore.store :more_data, {:foo=>"bar"}, {:expiry=>-3}
      @obstore.store :keep, {:foo=>"bar"}, {:expiry=>300}
      @obstore.store :never, {:foo=>"bar"}
    end

    it 'removes all expired records from the file' do
      @obstore._store.transaction do
        expect(@obstore._store.roots.length).to eq(4)
      end
      @obstore.compact!
      @obstore._store.transaction do
        expect(@obstore._store.roots.length).to eq(2)
        expect(@obstore._store.root?(:keep)).to eq(true)
        expect(@obstore._store.root?(:never)).to eq(true)
        expect(@obstore._store.root?(:data)).to eq(false)
      end
    end

  end

end