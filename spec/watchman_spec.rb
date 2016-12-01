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

      expect(@test_server.recvfrom(200).first).to eq("tagged.prod.no_tag.no_tag.no_tag.number.of.kittens:30|g")
    end

    context "a ':timing' type was passed" do
      it "sends a timing value to the server" do
        Watchman.submit("age.of.kittens", 30, type: :timing)

        sleep 1

        expect(@test_server.recvfrom(200).first).to eq("tagged.prod.no_tag.no_tag.no_tag.age.of.kittens:30|ms")
      end
    end

    context "an unrecognized type was passed" do
      it "raises an exception" do
        expect { Watchman.submit("age.of.kittens", 30, type: :hahha) }.to raise_exception(Watchman::SubmitTypeError)
      end
    end

    context "a tag was passed" do
      it "sends the value to statsd server" do
        Watchman.submit("number.of.kittens", 30, tags: ["mytag"])

        sleep 1

        expect(@test_server.recvfrom(200).first).to eq("tagged.prod.mytag.no_tag.no_tag.number.of.kittens:30|g")
      end
    end
  end

  describe ".increment" do
    it "increments the value of a metric" do
      Watchman.increment("number.of.kittens", tags: ["mytag"])

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("tagged.prod.mytag.no_tag.no_tag.number.of.kittens:1|c")
    end
  end

  describe ".decrement" do
    it "decrements the value of a metric" do
      Watchman.decrement("number.of.kittens", tags: ["mytag"])

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("tagged.prod.mytag.no_tag.no_tag.number.of.kittens:-1|c")
    end
  end

  describe ".benchmark" do
    it "measures the execution of the method in miliseconds" do
      Watchman.benchmark("sleep.time", tags: ["mytag"]) do
        sleep 1
      end

      sleep 1

      expect(@test_server.recvfrom(200).first).to match(/tagged\.prod\.mytag\.no_tag\.no_tag\.sleep\.time\:10\d\d|md/)
    end
  end
end
