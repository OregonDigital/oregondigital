require 'spec_helper'
require 'filemagic'

describe Audio do
  subject { FactoryGirl.build(:audio) }
  it "should instantiate" do
    expect {subject}.not_to raise_error
  end
  it "should save" do
    expect {subject.save!}.not_to raise_error
  end
  
  describe "#create_derivatives" do
    before do
      Audio.any_instance.stub(:audio_base_path).and_return(Rails.root.join("tmp", "audio"))
    end
    after do
      FileUtils.rm_rf(Rails.root.join("tmp", "audio"))
    end
    context "when it has an audio datastream" do
      subject { FactoryGirl.build(:audio, :with_audio_datastream) }
      before do
        subject.save
        subject.create_derivatives
      end
      it "should create an ogg" do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(subject.ogg_location).split(';')[0]
        expect(mime_type).to eq 'audio/ogg'
      end
      it 'should populate the external ogg datastream' do
        expect(subject.content_ogg.dsLocation).to eq("file://#{subject.ogg_location}")
        expect(Audio.find(subject.pid).content_ogg.dsLocation).to eq("file://#{subject.ogg_location}")
      end
      it "should create an mp3" do
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(subject.mp3_location).split(';')[0]
        expect(mime_type).to eq 'audio/mpeg'
      end
      it "should populate the external mp3 datastream" do
        expect(subject.content_mp3.dsLocation).to eq("file://#{subject.mp3_location}")
        expect(Audio.find(subject.pid).content_mp3.dsLocation).to eq("file://#{subject.mp3_location}")
      end
      it "should have a default thumb" do
        expect(subject.workflowMetadata.has_thumbnail).to eq true
        expect(File).to exist(Image.thumbnail_location(subject.pid))
      end
    end
  end
end
