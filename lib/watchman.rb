require "watchman/version"
require "benchmark"

module Watchman
  module_function

  require_relative "watchman/store"

  def prefix=(value)
    @prefix = value
  end

  def submit(name, value)
    Watchman::Store.save(metric_name_with_prefix(name), value)
  end

  def benchmark(name)
    result = nil

    time = Benchmark.measure do
      result = yield
    end

    submit(name, (time.real * 1000).floor)

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
