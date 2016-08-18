require 'spec_helper'

describe ActiveRecord::Coders::NestedHstore do
  class Post < ActiveRecord::Base
    serialize :properties, ActiveRecord::Coders::NestedHstore
    serialize :properties_with_default, ActiveRecord::Coders::NestedHstore
  end

  before :all do
    CreatePosts.up
  end

  after :all do
    CreatePosts.down
  end

  describe "dumping and loading" do
    context "with a nested hash" do
      let(:value) { { 'foo' => { 'bar' => 'baz' } } }

      it "preserves the value" do
        post = Post.new(properties: value)
        post.save!
        post.reload
        post.properties.should == value
      end
    end
  end

  describe "handling empty hstore" do
    it "should keep default value when saving empty" do
      post = Post.create!
      post.properties.should == {}
      post.properties_with_default.should == {}

      post.save!

      post.properties.should == {}
      post.properties_with_default.should == {}

      post.update_attributes(title: "testi")

      post.properties.should == {}
      post.properties_with_default.should == {}
    end
  end

  describe "accessing hash with symbols and string" do
    let(:symbol_value) { {foo_symbol: "bar 1"} }
    let(:string_value) { {"foo_string": "bar 2"} }
    let(:mixed_values) { symbol_value.merge(string_value) }

    it "should allow fetching symbol" do
      post = Post.create!(properties: symbol_value)
      post.reload

      post.properties[:foo_symbol].should == "bar 1"
      post.properties["foo_symbol"].should == "bar 1"
    end

    it "should allow fetching string" do
      post = Post.create!(properties: string_value)
      post.reload

      post.properties[:foo_string].should == "bar 2"
      post.properties["foo_string"].should == "bar 2"
    end

    it "should allow fetching string & symbol" do
      post = Post.create!(properties: mixed_values)
      post.reload

      post.properties[:foo_string].should == "bar 2"
      post.properties["foo_string"].should == "bar 2"
      post.properties[:foo_symbol].should == "bar 1"
      post.properties["foo_symbol"].should == "bar 1"
    end
  end
end
