# Watchman

Watchman is your friend who monitors your processes so you don't have to.

## Installation

``` ruby
gem 'watchman'
```

## Usage

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

## Global metric prefix

If you want to prepend all the metric names with a prefix, do the following:

``` ruby
Watchman.prefix = "production.server1"
```

Then, all your metrics will be saved with that prefix. For example:

``` ruby
Watchman.submit("high.score", 100) # => production.server1.high.score = 100
```
