= event_hook

* http://rubyforge.org/projects/seattlerb

== DESCRIPTION:

Wraps rb_add_event_hook so you can write fast ruby event hook
processors w/o the speed penalty that comes with set_trace_func (sooo
sloooow!). Calls back into ruby so you don't have to write C.

== FEATURES/PROBLEMS:

* Simple subclass design. Override ::process and you're off.
* Filters on calls/returns to not bog down on extraneous events.
* Not sure why process needs to be a class method. Will fix eventually.

== SYNOPSIS:

  class StupidTracer < EventHook
    self.process(*args)
      p args
    end
  end

== REQUIREMENTS:

* RubyInlien

== INSTALL:

* sudo gem install event_hook

== LICENSE:

(The MIT License)

Copyright (c) 2009 Ryan Davis, Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
