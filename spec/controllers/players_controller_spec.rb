require 'spec_helper'

describe PlayersController do

  describe "GET 'mini'" do
    it "returns http success" do
      get 'mini'
      response.should be_success
    end
  end

end
