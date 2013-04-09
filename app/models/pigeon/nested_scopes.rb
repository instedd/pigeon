module Pigeon
  module NestedScopes

    def find_attr_recursive(name, attributes)
      hash, key = find_attr_ref_recursive(name, attributes)
      hash && hash[key]
    end

    def find_attr_ref_recursive(name, attributes)
      fold_scoped_name(name, [attributes, nil]) do |(hash, key), name|
        if key.nil?
          [hash, name]
        elsif !hash.nil? && hash[key].is_a?(Hash)
          [hash[key], name]
        else
          [nil, nil]
        end
      end
    end

    def fold_scoped_name(name, initial, &block)
      m = name.to_s.match(/\A(?<name>\w+)(\[(?<nested>\w+)\](?<rest>.*))?\Z/)
      if m.nil?
        raise ArgumentError, "invalid scoped name #{name}"
      elsif m[:nested].nil?
        yield(initial, m[:name])
      else
        fold_scoped_name(m[:nested] + m[:rest], yield(initial, m[:name]), &block)
      end
    end

  end
end

