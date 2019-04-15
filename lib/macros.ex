defmodule Macros do
  defmacro print_var do
    quote do
      IO.inspect(var!(my_custom_var_name))
    end
  end
end

defmodule MacroCaller do
  require Macros

  def foo() do
    my_custom_var_name = "some random string"
    Macros.print_var()
  end
end
