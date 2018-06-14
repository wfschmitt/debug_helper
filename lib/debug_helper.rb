require 'yaml'

require 'debug_helper/version'

class DebugHelper

  def self.show(obj, name = obj.class)
    x = self._show(obj, name, info = {})
    STDOUT.puts x.to_yaml
    puts x.to_yaml
  end

  private

  def self._show(obj, name, info)
    # info.store('Item', "#{name} (#{obj.class.name})")
    x = case
          when obj.kind_of?(Array)
            self.show_array(obj, name, info)
          when obj.kind_of?(Hash)
            self.show_hash(obj, name, info)
          when obj.kind_of?(String)
            self.show_string(obj, name, info)
          when obj.kind_of?(Symbol)
            self.show_symbol(obj, name, info)
          # when obj.kind_of?(Range)
          # when obj.kind_of?(Set)
          # when obj.kind_of?(Struct)
          else
            "#{obj} (#{obj.class.name})"
        end
  end

  def self.show_array(obj, name, info)
    content = {}
    obj.each_with_index do |item, i|
      content.store("Element #{i}", self._show(item, i, {}))
    end
    label = "#{obj.class.name} (size=#{obj.size} name=#{name})"
    info.store(label, content)
    info
  end

  def self.show_hash(obj, name, info)
    content = {}
    obj.each_with_index do |pair, i|
      key, value = *pair
      # content.store(key, self._show(value, key, {}))
      pair = {'Key' => self._show(key, i, {}), 'Value' => self._show(value, i, {})}
      content.store("Pair #{i}", pair)
    end
    default = obj.default.nil? ? 'nil' : obj.default
    label = "#{obj.class.name} (size=#{obj.size} default=#{default} name=#{name})"
    info.store(label, content)
    info
  end

  def self.show_string(obj, name, info)
    label = "#{obj.class.name} (size=#{obj.size} encoding=#{obj.encoding} name=#{name})"
    info.store(label, [obj])
    info
  end

  def self.show_symbol(obj, name, info)
    label = "#{obj.class.name} (size=#{obj.size})"
    info.store(label, obj)
    info
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
