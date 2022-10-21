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

    describe "tags" do
      it "sends tags to the server" do
        Watchman.submit("age.of.kittens", 30, :timing, :tags => ["a", "b", "c"])

        sleep 1

        expect(@test_server.recvfrom(200).first).to eq("tagged.prod.a.b.c.age.of.kittens:30|ms")
      end

      context "less than 3 tags are passed" do
        it "fills the rest of the places with 'no_tag'" do
          Watchman.submit("age.of.kittens", 30, :timing, :tags => ["a"])

          sleep 1

          expect(@test_server.recvfrom(200).first).to eq("tagged.prod.a.no_tag.no_tag.age.of.kittens:30|ms")
        end
      end

      context "more than 3 tags are passed" do
        it "sends only three tags" do
          Watchman.submit("age.of.kittens", 30, :timing, :tags => [1, 2, 3, 4, 5])

          sleep 1

          expect(@test_server.recvfrom(200).first).to eq("tagged.prod.1.2.3.age.of.kittens:30|ms")
        end
      end
    end
  end

  describe ".submitfiltering" do
    before(:all) do
      Watchman.do_filter = true
    end
    
    after(:all) do
      Watchman.do_filter = false
    end

    it "filters out metrics if option external not provided" do
      Watchman.submit("age.of.kittens", 30, :timing, {external: true})

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("prod.age.of.kittens:30|ms")
      
      Watchman.submit("age.of.dogs", 10, :timing)
      Watchman.submit("age.of.kittens", 30, :timing, {external: true})

      sleep 1

      # should not see age.of.dogs recieved
      expect(@test_server.recvfrom(200).first).to eq("prod.age.of.kittens:30|ms")
    end
    
  end

  describe ".timing" do
    it "sends timing value" do
      Watchman.timing("speed.of.kittens", 30)

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("prod.speed.of.kittens:30|ms")
    end
  end

  describe ".increment" do
    it "increments the value of a metric" do
      Watchman.increment("number.of.kittens")

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("prod.number.of.kittens:1|c")
    end
  end

  describe ".decrement" do
    it "decrements the value of a metric" do
      Watchman.decrement("number.of.kittens")

      sleep 1

      expect(@test_server.recvfrom(200).first).to eq("prod.number.of.kittens:-1|c")
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
