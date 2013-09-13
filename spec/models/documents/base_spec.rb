require 'spec_helper'

describe Documents::Base do

  subject(:document) { Documents::Base.new }
  it "should instantiate" do
    expect{document}.not_to raise_error
  end

end