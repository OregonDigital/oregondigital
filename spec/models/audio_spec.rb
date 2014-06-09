require 'spec_helper'

describe Audio do
  subject { FactoryGirl.build(:audio) }
  it "should instantiate" do
    expect {subject}.not_to raise_error
  end
  it "should save" do
    expect {subject.save!}.not_to raise_error
  end
end
