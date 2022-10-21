require "watchman/version"
require "watchman/metric_name"
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
    attr_accessor :do_filter

    def benchmark(name, options = {})
      result = nil

      time = Benchmark.measure do
        result = yield
      end

      timing(name, (time.real * 1000).floor, options)

      result
    end

    def timing(name, value, options = {})
      submit(name, value, :timing, options)
    end

    def increment(name, options = {})
      submit(name, 1, :count, options)
    end

    def decrement(name, options = {})
      submit(name, -1, :count, options)
    end

    def submit(name, value, type = :gauge, options = {})
      return if skip?(options)

      metric = Watchman::MetricName.construct(name, prefix, options[:tags])

      case type
      when :gauge  then statsd_client.gauge(metric, value)
      when :timing then statsd_client.timing(metric, value)
      when :count  then statsd_client.count(metric, value)
      else raise SubmitTypeError.new("Submit type '#{type}' is not recognized")
      end
    end

    private

    def skip?(options)
      @do_filter && !options[:external]
    end

    def statsd_client
      if @test_mode == true
        Watchman::MockStatsd.new
      else
        @client ||= Statsd.new(@host, @port)
      end
    end
  end
end
