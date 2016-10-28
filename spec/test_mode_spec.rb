require "spec_helper"

describe "Watchman in test mode" do
  before(:all) do
    Watchman.prefix = "prod"
    Watchman.host = "localhost"
    Watchman.port = 15124
    Watchman.test_mode = true
  end

  after(:all) do
    Watchman.test_mode = false
  end

  describe ".submit" do
    it "uses the mock statsd client" do
      expect(Watchman::MockStatsd).to receive(:new).and_call_original

      Watchman.submit("number.of.kittens", 30)
    end
  end
end
