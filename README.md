# SendAt

Sends `msg` to `dest` at absolute `time` according to the erlang system time.
Similar to [`Process.send_after/4`](https://hexdocs.pm/elixir/Process.html#send_after/4)
except it supports an absolute time and is [time warp safe](http://erlang.org/doc/apps/erts/time_correction.html#id73340).

This is a work in progress!

## Installation

The package can be installed by adding `send_at` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:send_at, git: https://github.com/jlevycpa/send_at.git}
  ]
end
```

## Usage

Usage is nearly the same is as [`Process.send_after/4`](https://hexdocs.pm/elixir/Process.html#send_after/4) except
for the time argument. `time` can be a `DateTime` struct or a unix timestap. 

```
iex(1)> now = DateTime.utc_now()
#DateTime<2017-09-16 15:47:03.159000Z>
iex(2)> SendAt.send_at(self(), :foo, now)
#Reference<0.0.2.20>
iex(3)> flush()
:foo
:ok
iex(4)> later = System.system_time(:second) + 10
1505576926
iex(5)> SendAt.send_at(self(), :bar, later)
#Reference<0.0.2.32>
```

## Details

This function returns a timer reference.

This function is time warp safe, and corrects for time warps when required depending
on the configured erlang time warp mode.

In `no_time_warp` mode, adjustments to the OS time are reflected in the BEAM by adjusting
the frequency of erlang monotonic time, or leaping monotonic time forward or backward. In this case, a
timer is simply set for an absolute erlang monotonic time using `Process.send_after` with `abs: true`. No special handling of time warps is required and the `TimerServer` will not be started.

In `multi_time_warp` mode, the frequency of erlang monotonic time is constant. Time warps are handled by adjusting the time offset. All timers created are proxied through the `TimerServer`. The `TimerServer` subscribes to notifications of time warps from the BEAM. In the event of a time warp, all timers are canceled and recreated using the new time offset.

It should be noted that `no_time_wap` is the default mode for backwards compatability, although `multi_time_warp` is the recommended mode. The time warp mode is set using the +C erlang flag. This can be achieved by calling `elixir --erl "+C multi_time_warp"` or setting the `ELIXIR_ERL_OPTIONS="+C multi_time_warp"` in the environment. See the [erlang docs](http://erlang.org/doc/apps/erts/time_correction.html#id66654) for more information.

## Todo
* testing
* documentation
* better arg checking to make sure the TimerServer doesn't crash
* TimerServer should generate its own refs instead of passing through the ref from the erlang timer
* Add functions to cancel a timer and get its remaining time
