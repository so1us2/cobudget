require 'rails_helper'

describe "Users" do
  let(:round) { FactoryGirl.create(:round) }
  let(:user) { FactoryGirl.create(:user, force_password_reset: true) }

  let(:request_headers) { {
    "Accept" => "application/json",
    "Content-Type" => "application/json",
    "X-User-Token" => user.access_token,
    "X-User-Email" => user.email,
  } }

  describe "POST /users/:user_id/change_password" do
    context "if old password is correct it" do
      let(:password_params) {
        { user:
          { old_password: user.password,
            new_password: 'realgood'}
        }.to_json
      }

      before do
        post "/users/#{user.id}/change_password", password_params, request_headers
      end

      it "changes user's password " do
        expect(response.status).to eq 204
        expect(user.reload.valid_password?('realgood')).to eq true
      end

      it "turns off force_password_reset if enabled" do
        expect(user.reload.force_password_reset).to eq false
      end
    end

    it "doesn't change user's password if new password is too short" do
      password_params = { user:
        { old_password: user.password,
          new_password: 'a'}
      }.to_json

      post "/users/#{user.id}/change_password", password_params, request_headers

      body = JSON.parse(response.body)

      expect(response.status).to eq 400
      expect(body['errors']['password'][0]).to match("too short")
      expect(user.reload.valid_password?('a')).to eq false
      expect(user.reload.force_password_reset).to eq true
    end

    it "doesn't change user's password if old password is incorrect" do
      password_params = { user:
        { old_password: 'bad password',
          new_password: 'realgood'}
      }.to_json

      post "/users/#{user.id}/change_password", password_params, request_headers

      expect(user.reload.valid_password?('realgood')).to eq false
      expect(user.reload.force_password_reset).to eq true
      expect(response.status).to eq 400
    end
  end

  describe "GET /users/" do
    it "displays users" do
      user2 = FactoryGirl.create(:user)

      get "/users/", {}, request_headers

      expect(response.status).to eq 200 # success

      body = JSON.parse(response.body)
      names = []
      names << body["users"][0]["name"]
      names << body["users"][1]["name"]
      expect(names).to include(user.name)
      expect(names).to include(user2.name)
    end
  end
end
