class Outcome

  attr_reader :success, :result, :messages

  # Initializes an Outcome instance
  # @param[Boolean] success indicates if process was successful.
  # @param[Object] result the return value of the process. Anything you want to return
  # @param[Array<String>, optional] messages messages as Array of strings, optional
  def initialize(success, result, messages = [])
    @success, @result, @messages = success, result, messages
  end

  def success?
    @success
  end

  def messages_to_html
    @messages.join('<br/>').html_safe
  end

end
