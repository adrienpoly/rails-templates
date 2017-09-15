# frozen_string_literal: true

require 'rails_helper'

describe 'Factories testing' do
  FactoryGirl.factories.map(&:name).each do |factory_name|
    it "#{factory_name} is valid" do
      expect(create(factory_name)).to be_valid
      expect(build(factory_name)).to be_valid
    end
  end
end
