module Watchman::Store
  module_function

  def save(name, value)
    puts "#{name} -> #{value}"
  end
end
