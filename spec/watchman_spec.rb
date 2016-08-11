require "spec_helper"

describe Watchman do
  before(:all) do
    Watchman.prefix = "prod"
    Watchman.host = "localhost"
    Watchman.port = 15124

    @test_server = UDPSocket.new
    @test_server.bind(Watchman.host, Watchman.port)
  end

  it "has a version number" do
    expect(Watchman::VERSION).not_to be nil
  end

  describe ".submit" do
    it "sends the value to statsd server" do
      Watchman.submit("number.of.kittens", 30)

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("prod.number.of.kittens:30|g")
    end

    context "a ':timing' type was passed" do
      it "sends a timing value to the server" do
        Watchman.submit("age.of.kittens", 30, :timing)

        sleep 1

        expect(@test_server.recvfrom(200).first).to eq("prod.age.of.kittens:30|ms")
      end
    end

    context "an unrecognized type was passed" do
      it "raises an exception" do
        expect { Watchman.submit("age.of.kittens", 30, :hahha) }.to raise_exception(Watchman::SubmitTypeError)
      end
    end
  end

  describe ".benchmark" do
    it "measures the execution of the method in miliseconds" do
      Watchman.benchmark("sleep.time") do
        sleep 1
      end

      sleep 1

      expect(@test_server.recvfrom(200).first).to match(/prod\.sleep\.time\:10\d\d|md/)
    end
  end
end
