require "reform/form/dry"

Reform::Form.class_eval do
  include Reform::Form::Dry
end

# TODO: remove when patched
class Reform::Contract::Result::Errors
  def method_missing(method_name, *args)
    if "full_messages_for" == method_name.to_s
      param = args[0]
      @dotted_errors[param].collect { |message| "#{param} #{message}" }
    end
  end
end