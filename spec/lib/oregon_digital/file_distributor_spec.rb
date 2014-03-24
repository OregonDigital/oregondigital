require "spec_helper"
describe OregonDigital::FileDistributor do
  let(:fd) { OregonDigital::FileDistributor.new("oregondigital:45xzy4") }

  describe ".new" do
    it "should set a default depth of 2" do
      expect(fd.depth).to eq(2)
    end

    it "should default base_path to Rails.root / media" do
      expect(fd.base_path).to eq(Rails.root.join("media"))
    end
  end

  describe "#identifier" do
    it "should convert non-alphanumerics to hyphens" do
      expect(fd.identifier).to eq("oregondigital-45xzy4")
    end
  end

  describe "#filename" do
    it "should combine scrubbed identifier and extension to produce a filename" do
      fd.extension = ".jar"
      expect(fd.filename).to eq("oregondigital-45xzy4.jar")
    end
  end

  describe "#path" do
    it "should zero-pad the path" do
      fd.identifier = "27"
      fd.depth = 4
      expect(fd.path).to eq(fd.base_path.join("7/2/0/0/27").to_s)
    end

    it "should allow overriding base_path" do
      fd.base_path = "/var"
      expect(fd.path).to eq("/var/4/y/oregondigital-45xzy4")
    end

    it "should use extension as part of the path, but not alter the directory" do
      fd.extension = ".jpg"
      expect(fd.path).to eq(fd.base_path.join("4/y/oregondigital-45xzy4.jpg").to_s)
    end
  end
end
