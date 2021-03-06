alias Still.Compiler.{Incremental, Collections, ErrorCache, CompilationStage}

{:ok, _} = Application.ensure_all_started(:timex)

{:ok, _pid} = ErrorCache.start_link(%{})
{:ok, _pid} = Incremental.Registry.start_link(%{})
{:ok, _pid} = Collections.start_link(%{})
{:ok, _pid} = CompilationStage.start_link(%{})

ExUnit.start()

# Some templating engines need to redefine a module every time a particular
# file is rendered.
Code.compiler_options(ignore_module_conflict: true)
