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

    def submit(name, value, args = {})
      type = args[:type] || :gauge
      tags = args[:tags] || []

      metric = metric_name_with_prefix(name, tags)

      case type
      when :gauge  then statsd_client.gauge(metric, value)
      when :timing then statsd_client.timing(metric, value)
      when :count  then statsd_client.count(metric, value)
      else raise SubmitTypeError.new("Submit type '#{type}' is not recognized")
      end
    end

    def benchmark(name, args = {})
      tags = args[:tags] || []

      result = nil

      time = Benchmark.measure do
        result = yield
      end

      submit(name, (time.real * 1000).floor, type: :timing, tags: tags)

      result
    end

    def increment(name, args = {})
      tags = args[:tags] || []

      submit(name, 1, type: :count, tags: tags)
    end

    def decrement(name, args = {})
      tags = args[:tags] || []

      submit(name, -1, type: :count, tags: tags)
    end

    private

    def statsd_client
      if @test_mode == true
        Watchman::MockStatsd.new
      else
        @client ||= Statsd.new(@host, @port)
      end
    end

    def metric_name_with_prefix(name, tags)
      full_name = []
      full_name << "tagged"
      full_name << @prefix if @prefix
      full_name << tags_string(tags)
      full_name << name
      full_name.join(".")
    end

    def tags_string(tags)
      tags
        .fill("no_tag", tags.length, [3 - tags.length, 0].max)
        .first(3)
        .join(".")
    end
  end
end
