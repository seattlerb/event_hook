# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs("../../RubyInline/dev/lib",
                     "../../ZenTest/dev/lib")

Hoe.plugin :seattlerb
Hoe.plugin :inline

Hoe.spec 'event_hook' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = 'seattlerb'
  multiruby_skip << "1.9" << "trunk"
end

# vim: syntax=ruby
