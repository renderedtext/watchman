require "spec_helper"

describe Watchman::Store do
  before do
    Watchman.host = nil
  end

  describe ".save" do
    before do
      Watchman.host = "localhost"
      Watchman.port = 9999

      @received_message = nil

      @test_server = Thread.new do
        s = UDPSocket.new
        s.bind("localhost", 9999)

        text, sender = s.recvfrom(16)

        @received_message = text
      end
    end

    it "sends the message to the configured host" do
      sleep 1

      Watchman::Store.save("test.value", 40)

      sleep 1

      expect(@received_message).to eq("test.value:40|g")
    end
  end

end
