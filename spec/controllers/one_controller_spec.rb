require 'spec_helper'

describe OneController do

  describe "GET 'playlist'" do
    it "returns http success" do
      get 'playlist'
      response.should be_success
    end
  end

  describe "GET 'search'" do
    it "returns http success" do
      get 'search'
      response.should be_success
    end
  end

  describe "GET 'player'" do
    it "returns http success" do
      get 'player'
      response.should be_success
    end
  end

  describe "GET 'lyric'" do
    it "returns http success" do
      get 'lyric'
      response.should be_success
    end
  end

  describe "GET 'wiki'" do
    it "returns http success" do
      get 'wiki'
      response.should be_success
    end
  end

end
