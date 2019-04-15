defmodule User do
  use Validator.Struct
  defstruct ~w[id name email]a

  @external_resource path = Path.join(__DIR__, "forbidden_names.txt")
  @forbidden_names File.stream!(path, [], :line) |> Enum.map(&String.trim/1) |> IO.inspect()

  validate(:email, &is_binary/1)
  validate(:name, excludes: @forbidden_names)
  validate(:name, length: 4..20)
  validate(:email, :valid_email)
  validate(:email, length: 5..50)

  def new(email, name) do
    %__MODULE__{email: email, name: name}
  end
end

defimpl CanProtocol, for: User do
  def can?(%User{admin: false}, action, _file)
      when action in [:read, :touch],
      do: true

  def can?(%User{admin: false}, action, _file)
      when action in [:update, :destroy],
      do: false

  def can?(%User{admin: true}, action, _)
      when action in [:update, :read, :destroy, :touch],
      do: true

  def can?(%User{}, :create, _), do: true
end
