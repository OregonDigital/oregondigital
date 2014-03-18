shared_context "regular user", role: nil do
  let(:user) { FactoryGirl.create(:user) }
end

shared_context "submitter", role: :submitter do
  let(:user) { FactoryGirl.create(:submitter) }
end

shared_context "archivist", role: :archivist do
  let(:user) { FactoryGirl.create(:archivist) }
end

shared_context "for an admin", role: :admin do
  let(:user) { FactoryGirl.create(:admin) }
end
