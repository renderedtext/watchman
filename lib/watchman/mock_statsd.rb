class Watchman
  class MockStatsd

    # Used in test environments

    def gauge(metric, value, tags = {}); end
    def timing(metric, value, tags = {}); end
    def count(metric, value, tags = {}); end

  end
end
