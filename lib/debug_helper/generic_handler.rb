class DebugHelper

  class GenericHandler < Handler

    def show
      message_info = message.nil? ? '' : " (message='#{message}')"
      "#{obj.class.name}#{message_info} #{obj.inspect}"
    end

  end

end