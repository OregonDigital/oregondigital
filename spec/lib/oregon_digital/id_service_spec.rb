# -*- encoding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require "spec_helper"
describe OregonDigital::IdService do
  describe "create" do
    context "when the given id is free" do
      before(:each) do
        ActiveFedora::Base.should_receive(:exists?).at_least(1).times.and_return(false)
      end
      it "should return the namespaced id" do
        OregonDigital::IdService.create("monkeys").should == "#{OregonDigital::IdService.namespace}:monkeys"
      end
    end
    context "when the given id is taken" do
      before(:each) do
        ActiveFedora::Base.should_receive(:exists?).at_least(1).times.and_return(true)
      end
      it "should throw an exception" do
        expect {OregonDigital::IdService.create("monkeys")}.to raise_error
      end
    end
  end
  describe "#namespaceize" do
    before(:each) do
      OregonDigital::IdService.stub(:namespace).and_return("prefix")
    end
    it "should prepend the namespace" do
      OregonDigital::IdService.namespaceize("test").should == "prefix:test"
    end
  end
  describe "#noidify" do
    it "should return the last part of an identifier" do
      OregonDigital::IdService.noidify("prefix:test").should == "test"
    end
  end
  describe "mint" do
    before(:each) do
      # Hack config for ID Service
      OregonDigital::IdService.stub(:namespace).and_return("prefix")

      # Never hit the real fedora / solr for mint tests
      @afb = double("ActiveFedora::Base")
      stub_const("ActiveFedora::Base", @afb)
      @afb.stub(:exists? => false)

      # Mint an id for various tests
      @id = OregonDigital::IdService.mint
    end

    it "should prefix the id" do
      @id.should =~ /^prefix/
    end

    it "should validate the id is unique" do
      pid1 = double("Pid 1")
      pid2 = double("Pid 2")
      pid3 = double("Pid 3")
      @afb.should_receive(:exists?).with(pid1).and_return(true)
      @afb.should_receive(:exists?).with(pid2).and_return(true)
      @afb.should_receive(:exists?).with(pid3).and_return(false)

      OregonDigital::IdService.stub(:next_id).and_return(pid1, pid2, pid3)
      OregonDigital::IdService.mint.should eq(pid3)
    end

    it "should create a unique id" do
      @id.should_not be_empty
    end

    it "should not mint the same id twice in a row" do
      other_id = OregonDigital::IdService.mint
      other_id.should_not == @id
    end

    it "should create many unique ids" do
      a = []
      threads = (1..10).map do
        Thread.new do
          100.times do
            a <<  OregonDigital::IdService.mint
          end
        end
      end
      threads.each(&:join)
      a.uniq.count.should == a.count
    end

    it "should create many unique ids when hit by multiple processes " do
      rd, wr = IO.pipe
      2.times do
        pid = fork do
          rd.close
          threads = (1..10).map do
            Thread.new do
              20.times do
                wr.write OregonDigital::IdService.mint
                wr.write " "
              end
            end
          end
          threads.each(&:join)
          wr.close
        end
      end
      wr.close
      2.times do
        Process.wait
      end
      s = rd.read
      rd.close
      a = s.split(" ")
      a.uniq.count.should == a.count
    end
  end

end
