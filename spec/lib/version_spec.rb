require 'obstore/version'

describe 'ObStore::VERSION' do
  it 'returns a version string' do
    expect(ObStore::VERSION.class).to eq(String)
  end
end