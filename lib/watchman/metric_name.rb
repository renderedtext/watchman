class Watchman
  class MetricName
    def self.construct(base_name, prefix, tags)
      new(base_name, prefix, tags).construct
    end

    def initialize(base_name, prefix = nil, tags)
      @base_name = base_name
      @prefix = prefix
      @tags = tags || []
    end

    def construct
      full_name = []

      full_name << "tagged"      if tagged?
      full_name << @prefix       if @prefix
      full_name << formated_tags if tagged?
      full_name << @base_name

      full_name.join(".")
    end

    def formated_tags
      @tags
        .map(&:to_s)
        .fill("no_tag", @tags.length, [3 - @tags.length, 0].max)
        .first(3)
        .join(".")
    end

    def tagged?
      @tags.size > 0
    end
  end
end
