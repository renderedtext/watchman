# Watchman

Watchman is your friend who monitors your processes so you don't have to.

## Installation

``` ruby
gem "rt-watchman", :require => "watchman"
```

## Usage

First, set up the host and the port of the metrics server:

``` ruby
Watchman.host = "localhost"
Watchman.port = 22345
```

To submit a simple value from your service:

``` ruby
Watchman.submit("number.of.kittens", 30)
```

To benchmark a part of your service:

``` ruby
Watchman.benchmark("time.to.wake.up") do
  puts "Sleeping"
  sleep 10
  puts "Wake up"
end
```

To submit a time value in miliseconds:

``` ruby
Watchman.submit("number.of.kittens", 30, :timing)
```

## Global metric prefix

If you want to prepend all the metric names with a prefix, do the following:

``` ruby
Watchman.prefix = "production.server1"
```

Then, all your metrics will be saved with that prefix. For example:

``` ruby
Watchman.submit("high.score", 100) # => production.server1.high.score = 100
```

## Test mode for Watchman

In tests you can set the following:

``` ruby
Watchman.test_mode = true
```

That way watchman will use a stubbed client, and won't send any data to the
metric server.
