require "test/unit"
require "event_hook"

class Stupid < EventHook
  @@log = []

  def self.log
    @@log
  end

  def self.process(*a)
    @@log << a
  end
end

class TestEventHook < Test::Unit::TestCase
  def method_1
    method_2
  end

  def method_2
    method_3
  end

  def method_3
  end

  def test_sanity
    Stupid.start_hook
    method_1
    Stupid.stop_hook

    actual = Stupid.log.map { |id, obj, meth, klass|
      [EventHook::EVENTS[id], klass, meth]
    }

    expected = [[:return, Stupid,        :start_hook],
                [:call,   TestEventHook, :method_1],
                [:call,   TestEventHook, :method_2],
                [:call,   TestEventHook, :method_3],
                [:return, TestEventHook, :method_3],
                [:return, TestEventHook, :method_2],
                [:return, TestEventHook, :method_1],
                [:call,   Stupid,        :stop_hook],
                [:call,   Stupid,        :instance],
                [:return, Stupid,        :instance],
                [:ccall,  EventHook,     :remove_event_hook]]

    assert_equal expected, actual
  end
end
