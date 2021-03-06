defmodule Still.Compiler.PassThroughCopy do
  import Still.Utils

  require Logger

  def try(file) do
    case get_pass_through_copy_match(file) do
      {input_file, output_file} ->
        run(file, replace_match(file, input_file, output_file))

      output_file when not is_nil(output_file) ->
        run(file)

      _ ->
        :no_match
    end
  end

  defp run(file), do: run(file, file)

  defp run(file, output_file) do
    with :ok <- do_run(file, output_file) do
      Logger.info("Pass through copy #{file}")
      :ok
    else
      _ ->
        Logger.error("Failed to process #{file} in #{__MODULE__}")
        :error
    end
  end

  defp do_run(file, output_file) do
    get_output_path(output_file)
    |> Path.dirname()
    |> File.mkdir_p!()

    if File.dir?(get_input_path(file)) do
      process_folder(file, output_file)
    else
      process_file(file, output_file)
    end
  end

  defp process_file(file, output_file) do
    File.cp(get_input_path(file), get_output_path(output_file))
  end

  defp process_folder(folder, output_folder) do
    with {:ok, _} <- File.cp_r(get_input_path(folder), get_output_path(output_folder)) do
      :ok
    end
  end

  defp get_pass_through_copy_match(file) do
    Application.get_env(:still, :pass_through_copy, [])
    |> Enum.find(&match_pass_through_copy(file, &1))
  end

  defp match_pass_through_copy(file, {match, _output}) when is_binary(match),
    do: match_pass_through_copy(file, match)

  defp match_pass_through_copy(file, {match, _output}) when is_atom(match),
    do: match_pass_through_copy(file, match |> Atom.to_string())

  defp match_pass_through_copy(file, match) when is_binary(match),
    do: String.starts_with?(file, match)

  defp match_pass_through_copy(file, match) do
    cond do
      Regex.regex?(match) -> String.match?(file, match)
      true -> false
    end
  end

  defp replace_match(file, input_match, output_match) when is_atom(output_match),
    do: replace_match(file, input_match, output_match |> Atom.to_string())

  defp replace_match(file, input_match, output_match) when is_atom(input_match),
    do: replace_match(file, input_match |> Atom.to_string(), output_match)

  defp replace_match(file, input_match, output_match) do
    String.replace_prefix(file, input_match, output_match)
  end
end
