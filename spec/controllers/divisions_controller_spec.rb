require 'rails_helper'

RSpec.describe DivisionsController, type: :controller do
  describe 'authorization' do
    context "if the user is not logged in" do
      let!(:division) { Division.first || FactoryBot.create(:division, id: 1) }

      include_examples "tells user to login", :index
      include_examples "tells user to login", :edit, {id: 1}
      include_examples "tells user to login", :show, {id: 1}

      it 'denies user to destroy devisions' do
        post :destroy, params: {id: division.id}
        expect(response.status).to eq 302
        expect(flash[:alert]).to eq "You need to sign in or sign up before continuing."
      end

      it "denies user to update divisions" do
        post :update, params: {id: division.id, category: {name: 'test'}}
        expect(response.status).to eq 302
        expect(flash[:alert]).to eq "You need to sign in or sign up before continuing."
      end
    end

    context "if the user is in the correct group" do
      let!(:division) { Division.first || FactoryBot.create(:division, id: 1) }

      before(:each) do
        login_admin
      end

      include_examples "grants access", :index
      include_examples "grants access", :edit, {id: 1}
      include_examples "grants access", :show, {id: 1}

      it 'allows admin to destroy divisions' do
        division = FactoryBot.create(:division)
        post :destroy, params: {id: division.id}
        expect(response.status).to eq 302
        expect(flash[:notice]).to be_present
      end

      it "allows admin to update divisions" do
        post :update, params: {id: 1, division: {name: 'test'}}
        expect(response.status).to eq 302
        expect(flash[:notice]).to be_present
      end
    end
  end

  describe "GET #index" do
    subject(:index) {get :index}

    let!(:division1) {FactoryBot.create(:division, name: 'division 1')}
    let!(:division2) {FactoryBot.create(:division, name: 'division 2')}

    before(:each) do
      stub_login
      index
    end

    render_views

    it 'returns a "success" status code' do
      expect(response.code).to eq('200')
    end

    it 'lists out all divisions' do
      expect(response.body).to include(division1.name)
      expect(response.body).to include(division2.name)
    end
  end

  describe "GET #show" do
    subject(:show) {get :show, params: {id: division.id}}

    let!(:division) { FactoryBot.create(:division) }

    before(:each) do
      stub_login
      show
    end

    render_views

    it 'returns a "success" status code' do
      expect(response.code).to eq('200')
    end

    it 'lists out division' do
      expect(response.body).to include(division.name)
    end
  end

  describe "GET #edit" do
    subject(:edit) {get :edit, params: {id: division.id}}

    let!(:division) { FactoryBot.create(:division) }

    before(:each) do
      stub_login
      edit
    end

    render_views

    it 'returns a "success" status code' do
      expect(response.code).to eq('200')
    end

    it 'has the existing division name' do
      expect(response.body).to include(division.name)
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      subject(:update) {post :update, params: {id: division.id, division: {name: 'updated'}}}

      let!(:division) {FactoryBot.create(:division, name: 'my division')}

      before(:each) do
        stub_login
        update
      end

      it 'updated the existing division name' do
        division.reload
        expect(division.name).to eq 'updated'
      end

      it "redirects to the division" do
        put :update, params: {id: division.to_param, division: {name: 'updated'}}
        expect(response).to redirect_to(division)
      end
    end
  end

  describe "DELETE #destroy" do
    subject(:destroy) {post :destroy, params: {id: division.id}}

    let!(:division) {FactoryBot.create(:division, name: 'delete me')}

    before(:each) do
      stub_login
      destroy
    end

    it 'updated the existing role name' do
      names = Division.pluck(:name)
      expect(names).to_not include 'delete me'
    end
  end
end
