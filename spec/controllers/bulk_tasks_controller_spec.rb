require 'spec_helper'

describe BulkTasksController do
  
  let(:task) { double(BulkTask.new(:directory => 'tmp')) }
  let(:task2) { double(BulkTask.new(:directory => 'tmp2')) }

  before do
    ActionController::Base.any_instance.stub(:can? => true)
    BulkTask.stub(:find).and_return(task)
    BulkTask.stub(:all).and_return([task, task2])
    task.stub(:directory).and_return('./tmp')
  end

  describe '#index' do
    before do
      BulkTask.stub(:refresh)
    end

    it 'refreshes bulk tasks' do
      expect(BulkTask).to receive(:refresh).once
      get :index
    end

    it 'gives all bulk task items' do
      get :index
      expect(assigns[:tasks]).to eq [task, task2]
    end
  end
  
  describe '#show' do
    it 'gives the bulk task item' do
      get :show, :id => '1'
      expect(assigns(:task)).to eq task
    end
  end

  describe '#ingest' do
    it 'adds task to queue' do
      task.stub(:enqueue)
      expect(task).to receive(:enqueue)
      post :ingest, :id => '1'
    end
  end

  describe '#reset_task' do
    it 'resets the task' do
      task.stub(:reset!)
      expect(task).to receive(:reset!)
      post :reset_task, :id => '1'
    end
  end

  describe '#review_all' do
    it 'reviews all items in task' do
      task.stub(:queue_review)
      task.stub(:asset_ids).and_return(['1', '2'])
      expect(task).to receive(:queue_review).once
      post :review_all, :id => '1'
    end
  end

  describe '#delete_all' do
    it 'deletes all items in task' do
      task.stub(:queue_delete)
      task.stub(:asset_ids).and_return(['1', '2'])
      expect(task).to receive(:queue_delete).once
      post :delete_all, :id => '1'
    end
  end
end
