require 'spec_helper'

describe BulkTasksController do
  
  # let(:task) { double(BulkTask.new(:directory => 'tmp')) }

  # before do
  #   ActionController::Base.any_instance.stub(:can? => true)
  #   # BulkTask.stub(:find).and_return(task)
  # end

  # describe '#index' do
  #   it 'refreshes bulk tasks' do
  #     BulkTask.stub(:refresh)
  #     expect(BulkTask).to receive(:refresh).once
  #     get :index

  #   end
  # end
  
  # describe '#show' do
  #   it 'gives the bulk task item' do
  #     expect(assigns(:tasks)).to be_a BulkTask
  #   end
  # end

  # describe '#ingest' do
  #   it 'adds task to queue' do
  #     expect(task).to receive(:enqueue)
  #     post :ingest, :id => '1'
  #   end
  # end

  # describe '#reset_task' do
  #   task.stub(:reset)
  #   expect(task).to receive(:reset)
  #   post :reset_task, :id => '1'
  # end

  # describe '#review_all' do
  #   BulkTask.stub(:review_all)
  #   expect(BulkTask).to receive(:delete_all)
  #   post :review_all
  # end

  # describe '#delete_all' do
  #   BulkTask.stub(:delete_all)
  #   expect(BulkTask).to receive(:delete_all)
  #   post :delete_all
  # end
end
