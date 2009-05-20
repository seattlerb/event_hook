#!/usr/bin/env ruby -w

require 'benchmark'

$: << 'lib'
require 'rubygems'
require 'event_hook'

class Demo < EventHook
  def self.process(*ignore)
  end

  def call_a_method
    a_method
  end

  def a_method
  end
end

SET_TRACE_FUNC_PROC = proc { |e, f, l, m, b, c|
  # do nothing
}

max = (ARGV.shift || 1_000_000).to_i

demo = Demo.instance

puts "# of iterations = #{max}"
Benchmark::bm(20) do |x|
  x.report("null_time") do
    for i in 0..max do
      # do nothing
    end
  end

  x.report("ruby time") do
    for i in 0..max do
      demo.call_a_method
    end
  end

  Demo.start_hook
  x.report("event hook") do
    for i in 0..max do
      demo.call_a_method
    end
  end
  Demo.stop_hook

  set_trace_func SET_TRACE_FUNC_PROC
  x.report("set_trace_func") do
    for i in 0..max do
      demo.call_a_method
    end
  end
  set_trace_func nil
end
