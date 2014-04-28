require 'spec_helper'

describe DownloadsController do
  let(:image) { image = FactoryGirl.create(:image, :with_jpeg_datastream) }
  describe '#show' do
    context "for an image" do
      before do
        image.create_derivatives
        DownloadsController.any_instance.stub(:asset).and_return(image)
      end
      context "(when a user is not authenticated)" do
        context "(with no requested datastream)" do
          it "should return the medium datastream" do
            expect(image.datastreams).to receive(:[]).with("medium").at_least(1).times.and_call_original
            get :show, :id => image.pid
          end
        end
        # TODO: Review these permissions.
        context "(when requesting the content datastream)" do
          it "should not be a success" do
            expect{get :show, :id => image.pid, :datastream_id => "content"}.to raise_error(Hydra::AccessDenied)
          end
        end
      end
      context "(when a user is an admin)" do
        let(:user) {FactoryGirl.create(:admin)}
        before do
          sign_in user
        end
        context "(when requesting the content datastream)" do
          it "(should be a success)" do
            get :show, :id => image.pid, :datastream_id => "content"
            expect(response).to be_success
          end
        end
      end
    end
    context "for a document" do
      let(:document) { FactoryGirl.create(:document, :with_pdf_datastream) }
      before do
        DownloadsController.any_instance.stub(:asset).and_return(document)
      end
      context "(when a user is not authenticated)" do
        context "(with no requested datastream)" do
          it "should error" do
            expect{get :show, :id => document.pid}.to raise_error(Hydra::AccessDenied)
          end
        end
      end
      context "(when a user is an admin)" do
        let(:user) {FactoryGirl.create(:admin)}
        before do
          sign_in user
        end
        context "(when requesting the content datastream)" do
          it "(should be a success)" do
            get :show, :id => image.pid, :datastream_id => "content"
            expect(response).to be_success
          end
        end
      end
    end
  end
end
