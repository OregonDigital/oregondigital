require "spec_helper"
describe OregonDigital::FileDistributor do
  let(:fd) { OregonDigital::FileDistributor.new("oregondigital:45xzy4") }

  it "should set a default depth of 2" do
    expect(fd.depth).to eq(2)
  end

  it "should default base_path to Rails.root / media" do
    expect(fd.base_path).to eq(Rails.root.join("media"))
  end

  it "should convert non-alphanumerics to hyphens" do
    expect(fd.path).to eq(fd.base_path.join("4/y/oregondigital-45xzy4").to_s)
  end

  it "should zero-pad the path" do
    fd.identifier = "27"
    fd.depth = 4
    expect(fd.path).to eq(fd.base_path.join("7/2/0/0/27").to_s)
  end

  it "should allow overriding base_path" do
    fd.base_path = "/var"
    expect(fd.path).to eq("/var/4/y/oregondigital-45xzy4")
  end
end
