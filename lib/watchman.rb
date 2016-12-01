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

    def submit(name, value, type = :gauge, tags_list = [])
      metric = metric_name_with_prefix(name, tags_list)

      case type
      when :gauge  then statsd_client.gauge(metric, value)
      when :timing then statsd_client.timing(metric, value)
      when :count  then statsd_client.count(metric, value)
      else raise SubmitTypeError.new("Submit type '#{type}' is not recognized")
      end
    end

    def benchmark(name, tags_list = [])
      result = nil

      time = Benchmark.measure do
        result = yield
      end

      submit(name, (time.real * 1000).floor, :timing, tags_list)

      result
    end

    def increment(name, tags_list = [])
      submit(name, 1, :count, tags_list)
    end

    def decrement(name, tags_list = [])
      submit(name, -1, :count, tags_list)
    end

    private

    def statsd_client
      if @test_mode == true
        Watchman::MockStatsd.new
      else
        @client ||= Statsd.new(@host, @port)
      end
    end

    def metric_name_with_prefix(name, tags_list)
      full_name = []
      full_name << "tagged"
      full_name << @prefix if @prefix
      full_name << tags(tags_list)
      full_name << name
      full_name.join(".")
    end

    def tags(tags_list)
      tags_list
        .fill("no_tag", tags_list.length, [3 - tags_list.length, 0].max)
        .first(3)
        .join(".")
    end
  end
end
