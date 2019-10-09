use Mix.Config

config :absinthe_paginator, ecto_repos: [AbsinthePaginatorTest.Repo]

config :absinthe_paginator, AbsinthePaginatorTest.Repo,
  database: "absinthe_paginator_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432",
  poolsize: 10,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
