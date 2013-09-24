
shared_examples 'a baggable item' do
  let(:item) do
    i = described_class.new
    i.save
    i
  end

  it 'should be baggable' do
    expect { item.write_bag }.not_to raise_error
  end

end
