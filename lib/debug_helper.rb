require 'debug_helper/version'

class DebugHelper

  def self.show(obj, label = obj.class)
    case
      # when obj.kind_of?(Array)
      when obj.kind_of?(Hash)
        self.show_hash(obj, label)
      # when obj.kind_of?(Range)
      # when obj.kind_of?(Set)
      # when obj.kind_of?(Struct)
      else
        STDOUT.puts ['ELSE', obj.class, obj]
        # self.show_object(obj, label)
    end
  end

  def self.show_hash(hash, label = hash.class.name)
    self.kind_of!(hash, Hash)
    lines = [
        "Label:  #{label}",
        "Count:  #{hash.size}",
    ]
    hash.to_a.each_with_index do |pair, i|
      key, value = *pair
      lines.push("  Pair #{i}:")
      lines.push("    Key (#{key.class.name}): #{key.inspect}")
      lines.push("    Value (#{value.class.name}): #{value.inspect}")
    end
    lines.push('')
    lines.join("\n")
    puts lines
  end

  def self.respond_to!(obj, method)
    unless obj.respond_to?(method)
      message = "Instance of #{obj.class.name} does not respond to :#{method}"
      raise ArgumentError.new(message)
    end
  end

  def self.kind_of!(obj, klass)
    unless obj.kind_of?(klass)
      message = "Instance of #{obj.class.name} is not a kind of #{klass}"
      raise ArgumentError.new(message)
    end
  end

end
