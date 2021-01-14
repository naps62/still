defmodule Still.Compiler.File do
  require Logger

  alias Still.{SourceFile, Preprocessor, Profiler}

  def compile(input_file) do
    %SourceFile{input_file: input_file, run_type: :compile}
    |> run_preprocessor()
    |> case do
      %SourceFile{} = file ->
        {:ok, file}

      msg ->
        Logger.error("Failed to compile #{input_file}")
        msg
    end
  end

  def render(input_file, metadata) do
    file = %SourceFile{input_file: input_file, metadata: metadata}

    with %SourceFile{} = file <- run_preprocessor(file) do
      Logger.debug("Rendered #{input_file}")
      file
    else
      msg ->
        Logger.error("Failed to render #{input_file}")
        msg
    end
  end

  defp run_preprocessor(file) do
    if profilling?() do
      run_preprocessor_with_profiler(file)
    else
      run_preprocessor_without_profiler(file)
    end
  end

  defp run_preprocessor_with_profiler(file) do
    start_time = Profiler.timestamp()

    case Preprocessor.run(file) do
      %SourceFile{} = response ->
        end_time = Profiler.timestamp()
        Profiler.register(response, end_time - start_time)

        response

      error ->
        error
    end
  end

  defp run_preprocessor_without_profiler(file) do
    Preprocessor.run(file)
  end

  defp profilling? do
    Application.get_env(:still, :profiler, false)
  end
end
