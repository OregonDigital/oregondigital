
shared_examples 'a baggable item' do
  let(:item) do
    i = described_class.new
    i.save
    i
  end

  it 'should be baggable' do
    MIME::Types.stub(:[]).and_call_original
    extensions = ["nt"]
    results = double()
    results.stub(:extensions).and_return(extensions)
    MIME::Types.stub(:[]).with("application/n-triples").and_return([results])
    expect { item.write_bag }.not_to raise_error
  end

end
