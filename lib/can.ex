defmodule Can do
  defmacro can?(subject, {action, _, [argument]}) do
    quote do
      CanProtocol.can?(unquote(subject), unquote(action), unquote(argument))
    end
  end
end

defprotocol CanProtocol do
  def can?(subject, action, resource)
end
