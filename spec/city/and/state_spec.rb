# frozen_string_literal: true

RSpec.describe CityState do
  it "has a version number" do
    expect(CityState::VERSION).not_to be nil
  end

  describe ".countries" do
    it "returns an array (possibly empty)" do
      expect(described_class.countries).to be_a(Array)
    end
  end

  describe ".states" do
    it "returns empty array for blank country" do
      expect(described_class.states(nil)).to eq([])
      expect(described_class.states("")).to eq([])
    end
  end

  describe ".cities" do
    it "returns empty array for blank country" do
      expect(described_class.cities(nil)).to eq([])
      expect(described_class.cities("")).to eq([])
    end
  end
end
