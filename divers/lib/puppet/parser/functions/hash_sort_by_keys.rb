module Puppet::Parser::Functions
      newfunction(:hash_sort_by_keys, :type => :rvalue) do |args|
        Hash[args[0].sort_by { |k,v| k }]
      end
end

