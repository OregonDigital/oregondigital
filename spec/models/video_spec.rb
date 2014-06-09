require 'spec_helper'

describe Video do
  subject { FactoryGirl.build(:video) }
  it "should instantiate" do
    expect {subject}.not_to raise_error
  end
  it "should save" do
    expect {subject.save!}.not_to raise_error
  end
end
