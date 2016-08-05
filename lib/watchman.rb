require "watchman/version"
require "benchmark"
require "statsd"

module Watchman
  extend self

  attr_accessor :prefix
  attr_accessor :host
  attr_accessor :port

  def statsd_client
    @client ||= Statsd.new(@host, @port)
  end

  def submit(name, value)
    statsd_client.gauge(metric_name_with_prefix(name), value)
  end

  def benchmark(name)
    result = nil

    time = Benchmark.measure do
      result = yield
    end

    statsd_client.timing(metric_name_with_prefix(name), (time.real * 1000).floor)

    result
  end

  def metric_name_with_prefix(name)
    if @prefix
      "#{@prefix}.#{name}"
    else
      name
    end
  end
end
