require "spec_helper"

describe Watchman do
  before do
    Watchman.prefix = nil
  end

  it "has a version number" do
    expect(Watchman::VERSION).not_to be nil
  end

  describe ".submit" do
    it "saves the value in the store" do
      expect(Watchman::Store).to receive(:save).with("number.of.kittens", 30)

      Watchman.submit("number.of.kittens", 30)
    end

    context "when a global prefix exists" do
      before do
        Watchman.prefix = "prod"
      end

      it "saves the metric with that prefix" do
        expect(Watchman::Store).to receive(:save).with("prod.number.of.kittens", 30)

        Watchman.submit("number.of.kittens", 30)
      end
    end
  end

  describe ".benchmark" do
    it "measures the execution of the method in miliseconds" do
      expect(Watchman::Store).to receive(:save) do |name, value|
        expect(name).to eq("sleep.time")
        expect(value).to be_within(10).of(1000)
      end

      Watchman.benchmark("sleep.time") do
        sleep 1
      end
    end
  end
end
