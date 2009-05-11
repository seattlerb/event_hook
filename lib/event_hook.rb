require 'inline'
require 'singleton'

class EventHook

  include Singleton

  ##
  # Ruby events that EventHook notifies you about.

  EVENTS = {
    0x00 => :none,
    0x01 => :line,
    0x02 => :class,
    0x04 => :end,
    0x08 => :call,
    0x10 => :return,
    0x20 => :ccall,
    0x40 => :creturn,
    0x80 => :raise,
    0xff => :all,
  }

  def self.start_hook
    self.instance.add_event_hook
  end

  def self.stop_hook
    self.instance.remove_event_hook
  end

  ##
  # Redefine me in a subclass.  +args+ is [event_id, self, method, class].

  def self.process(*args)
    # do nothing
  end

  inline(:C) do |builder|

    builder.add_type_converter("rb_event_t", '', '')
    builder.add_type_converter("ID", '', '')
    builder.add_type_converter("NODE *", '', '')

    builder.include '<time.h>'
    builder.include '"ruby.h"'
    builder.include '"node.h"'

    builder.prefix <<-'EOF'
      static VALUE event_hook_klass = Qnil;
      static ID method = 0;
      static int in_event_hook = 0;
      static VALUE argv[4];
    EOF

    builder.c_raw <<-'EOF'
    static void
    event_hook(rb_event_t event, NODE *node, VALUE self, ID mid, VALUE klass) {

      if (in_event_hook) return;
      if (mid == ID_ALLOCATOR) return;

      in_event_hook++;

      if (NIL_P(event_hook_klass)) event_hook_klass = self;
      if (method == 0) method = rb_intern("process");

      if (klass) {
        if (TYPE(klass) == T_ICLASS) {
          klass = RBASIC(klass)->klass;
        } else if (FL_TEST(klass, FL_SINGLETON)) {
          klass = self;
        }
      }

      argv[0] = UINT2NUM(event);
      argv[1] = self;
      argv[2] = ID2SYM(mid);
      argv[3] = klass;
      rb_funcall2(event_hook_klass, method, 4, argv);

      in_event_hook--;
    }
    EOF

    builder.c <<-'EOF'
      void add_event_hook() {
        rb_add_event_hook(event_hook, RUBY_EVENT_CALL | RUBY_EVENT_RETURN | RUBY_EVENT_C_CALL | RUBY_EVENT_C_RETURN);
      }
    EOF

    builder.c <<-'EOF'
      void remove_event_hook() {
        rb_remove_event_hook(event_hook);
        event_hook_klass = Qnil;
      }
    EOF

  end

end
