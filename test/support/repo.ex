defmodule AbsinthePaginatorTest.Repo do
  use Ecto.Repo,
    otp_app: :absinthe_paginator,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end

defmodule AbsinthePaginatorTest.Item do
  use Ecto.Schema

  schema "items" do
    field(:title, :string)
  end
end
