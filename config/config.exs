import Config

config :still,
  view_helpers: [],
  dev_layout: false,
  url_fingerprinting: false,
  preprocessors: %{
    ".svg" => [Still.Preprocessor.AddContent]
  }

config :mogrify,
  mogrify_command: [
    path: "mogrify",
    args: []
  ]

config :mogrify,
  convert_command: [
    path: "convert",
    args: []
  ]

import_config("#{Mix.env()}.exs")
