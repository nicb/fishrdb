#
# $Id: kernel_extensions.rb 455 2009-10-03 00:38:34Z nicb $
#
module Kernel

private

  def method_name # will be superseded by __method__ in ruby 1.9
    caller[0] =~ /`([^']*)'/ and $1
  end

end
