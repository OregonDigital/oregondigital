require 'spec_helper'

describe Video do
  subject { FactoryGirl.build(:video) }
  it "should instantiate" do
    expect {subject}.not_to raise_error
  end
  it "should save" do
    expect {subject.save!}.not_to raise_error
  end
  describe "#create_derivatives" do
    before do
      Video.any_instance.stub(:video_base_path).and_return(Rails.root.join("tmp", "video"))
    end
    after do
      FileUtils.rm_rf(Rails.root.join("tmp", "video"))
    end
    context "when it has a video datastream" do
      subject { FactoryGirl.build(:video, :with_video_datastream) }
      before do
        subject.save
        subject.create_derivatives
      end
      it "should create a webm" do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(subject.webm_location).split(';')[0]
        expect(mime_type).to eq 'video/webm'
      end
      it 'should populate the external webm datastream' do
        expect(subject.content_webm.dsLocation).to eq("file://#{subject.webm_location}")
        expect(Video.find(subject.pid).content_webm.dsLocation).to eq("file://#{subject.webm_location}")
      end
      it "should create an mp4" do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(subject.mp4_location).split(';')[0]
        expect(mime_type).to eq 'video/mp4'
      end
      it "should populate the external mp4 datastream" do
        expect(subject.content_mp4.dsLocation).to eq("file://#{subject.mp4_location}")
        expect(Video.find(subject.pid).content_mp4.dsLocation).to eq("file://#{subject.mp4_location}")
      end
    end
  end
end
