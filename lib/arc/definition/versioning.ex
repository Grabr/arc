defmodule Arc.Definition.Versioning do
  defmacro __using__(_) do
    quote do
      @versions [:original]
      @before_compile Arc.Definition.Versioning
    end
  end

  def resolve_file_name(definition, version, {file, scope}) do
    resolve_file_name(definition, version, {file, scope}, Application.get_env(:arc, :secret))
  end

  defp resolve_file_name(definition, version, {file, scope}, nil) do
    name = definition.filename(version, {file, scope})
    conversion = definition.transform(version, {file, scope})

    case conversion do
      {_, _, ext} -> "#{name}.#{ext}"
       _          -> "#{name}#{Path.extname(file.file_name)}"
    end
  end
  defp resolve_file_name(definition, version, {file, scope}, secret) do
    file_name = resolve_file_name(definition, version, {file, scope}, nil)
    token     = :crypto.hmac(:sha, secret, file_name) |> Base.encode16 |> String.downcase
    token <> file_name
  end

  defmacro __before_compile__(_env) do
    quote do
      def transform(_, _), do: :noaction
      def __versions, do: @versions
    end
  end
end
