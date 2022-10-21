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

To submit a value to statsd from your service use:

``` ruby
Watchman.submit(name, value, type)
```

Available types:
* :gauge `default`
* :timing
* :count

Submitting a simple gauge value from your service would look like:

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

To submit a time value in milliseconds use:

``` ruby
Watchman.submit("number.of.kittens", 30, :timing)
```

To submit a count value use:

``` ruby
# To increse:
Watchman.increment("number.of.kittens")

# or decrese:
Watchman.decrement("number.of.kittens")
```

Alternatively you can use:

``` ruby
# To increse:
Watchman.submit("number.of.kittens", 1, :count)

# or decrese:
Watchman.submit("number.of.kittens", -1, :count)
```

to achieve the equivalent effect, with the added possibility of tweaking the
value.

## Tags

If you want to use a variable that changes often, don't use this:

``` ruby
Watchman.submit("user.#{id}", 30)
```

Use tags. A list of tags is an optional last parameter of `:submit`, `:benchmark`,
`:increment` and `:decrement` methods.

``` ruby
Watchman.submit("user", 30, tags: [id])
```

Tags list is limited to 3 values.

## Global metric prefix

If you want to prepend all the metric names with a prefix, do the following:

``` ruby
Watchman.prefix = "production.server1"
```

Then, all your metrics will be saved with that prefix. For example:

``` ruby
Watchman.submit("high.score", 100) # => production.server1.high.score = 100
```

## Filtering metrics

If you want to filter metrics based on some condition, do the foloowing:

```ruby
Watchman.do_filter = true
```

Then none of the metrics without options flag ```external``` will be ignored and 
only metrics like the following will be sent out:
```ruby
Watchman.submit("number.of.puppies", 3, :gauge, {external: true})
```

## Test mode for Watchman

In tests you can set the following:

``` ruby
Watchman.test_mode = true
```

That way watchman will use a stubbed client, and won't send any data to the
metric server.
