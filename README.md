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
