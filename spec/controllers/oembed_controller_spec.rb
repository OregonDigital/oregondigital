require 'spec_helper'

describe OembedController, :resque => true do

 describe '#traffic_control' do
   context 'when given a request' do
     context 'if asset is nil' do
       it 'should return a 404'
       end
     end
     context 'if asset is not public' do
       it 'should return a 501' do
       end
     end
     context 'if asset is not an image' do
       it 'should return a 401' do
       end
     end
     context 'if asset is an image' do
       it 'should call image_responder' do
       end
     end
   end

  describe '#image_responder' do
    context 'when given an asset' do
      context 'if the asset has no location' do
        it 'should return a 401'
        end
      end
      context 'if the asset has a location' do
        it 'should call the 
