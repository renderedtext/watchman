require "watchman/version"
require "watchman/mock_statsd"
require "benchmark"
require "statsd"

class Watchman
  class SubmitTypeError < RuntimeError; end

  class << self
    attr_accessor :prefix
    attr_accessor :host
    attr_accessor :port
    attr_accessor :test_mode

    def submit(name, value, type = :gauge)
      metric = metric_name_with_prefix(name)

      case type
      when :gauge  then statsd_client.gauge(metric, value)
      when :timing then statsd_client.timing(metric, value)
      when :count  then statsd_client.count(metric, value)
      else raise SubmitTypeError.new("Submit type '#{type}' is not recognized")
      end
    end

    def benchmark(name)
      result = nil

      time = Benchmark.measure do
        result = yield
      end

      submit(name, (time.real * 1000).floor, :timing)

      result
    end

    def increment(name)
      submit(name, 1, :count)
    end

    def decrement(name)
      submit(name, -1, :count)
    end

    private

    def statsd_client
      if @test_mode == true
        Watchman::MockStatsd.new
      else
        @client ||= Statsd.new(@host, @port)
      end
    end

    def metric_name_with_prefix(name)
      if @prefix
        "#{@prefix}.#{name}"
      else
        name
      end
    end
  end
end
