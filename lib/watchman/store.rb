module Watchman::Store
  module_function

  def save(name, value)
    message = "#{name}|#{value}"

    puts "Sending [#{Watchman.host}:#{Watchman.port}]:#{message}"

    UDPSocket.new.send(message, 0, Watchman.host, Watchman.port)
  end
end
