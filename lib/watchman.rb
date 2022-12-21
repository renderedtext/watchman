require "watchman/version"
require "watchman/tagged_metric_name"
require "watchman/untagged_metric_name"
require "watchman/mock_statsd"
require "benchmark"
require "datadog/statsd"

class Watchman
  class SubmitTypeError < RuntimeError; end

  class << self
    attr_accessor :prefix
    attr_accessor :host
    attr_accessor :port
    attr_accessor :test_mode
    attr_accessor :do_filter
    attr_accessor :external_backend

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

      meetric = ""
      tags = []
      if @external_backend == :aws_cloudwatch
        metric = Watchman::UntaggedMetricName.construct(name, prefix)
        tags = options[:tags]
      else
        metric = Watchman::TaggedMetricName.construct(name, prefix, options[:tags])
        tags = []
      end

      case type
      when :gauge  then statsd_client.gauge(metric, value, tags: tags)
      when :timing then statsd_client.timing(metric, value, tags: tags)
      when :count  then statsd_client.count(metric, value, tags: tags)
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
        @client ||= Datadog::Statsd.new(@host, @port, single_thread: true, buffer_max_pool_size: 1)
      end
    end
  end
end
