require 'inline'
require 'singleton'

class EventHook
  VERSION = '1.1.1'

  include Singleton

  NONE    = 0x00
  LINE    = 0x01
  CLASS   = 0x02
  NND     = 0x04
  CALL    = 0x08
  RETURN  = 0x10
  CCALL   = 0x20
  CRETURN = 0x40
  RAISE   = 0x80
  ALL     = 0xff

  ##
  # Ruby events that EventHook notifies you about.

  EVENTS = {
    LINE    => :line,
    CLASS   => :class,
    NND     => :end,
    CALL    => :call,
    RETURN  => :return,
    CCALL   => :ccall,
    CRETURN => :creturn,
    RAISE   => :raise,
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
    raise NotImplementedError, "subclass responsibility"
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

      if (NIL_P(event_hook_klass)) {
        int t = rb_type(self);
        if (t == T_CLASS || t == T_MODULE) {
          event_hook_klass = self;
        } else {
          event_hook_klass = CLASS_OF(self);
        }
      }

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
        rb_add_event_hook(event_hook, RUBY_EVENT_CALL | RUBY_EVENT_RETURN |
                                      RUBY_EVENT_C_CALL | RUBY_EVENT_C_RETURN);
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
