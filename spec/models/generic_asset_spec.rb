require 'spec_helper'

describe GenericAsset do
  subject(:generic_asset) {GenericAsset.new}
  it "should initialize" do
    expect(generic_asset).not_to raise_error
  end
end