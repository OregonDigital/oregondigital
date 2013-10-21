require "spec_helper"
describe OregonDigital::FileDistributor do
  let(:fd) { OregonDigital::FileDistributor.new("oregondigital:45xzy4") }

  it "should set a default depth of 2" do
    expect(fd.depth).to eq(2)
  end

  it "should not have a default base_path" do
    expect(fd.base_path).to be_nil
  end

  it "should convert non-alphanumerics to hyphens" do
    expect(fd.path).to eq("4/y/oregondigital-45xzy4")
  end

  it "should zero-pad the path" do
    fd.identifier = "27"
    fd.depth = 4
    expect(fd.path).to eq("7/2/0/0/27")
  end

  it "should prefix with base_path if set" do
    fd.base_path = "/var"
    expect(fd.path).to eq("/var/4/y/oregondigital-45xzy4")
  end
end
