# AbsinthePaginator

AbsinthePaginator helps connecting the packages :absinthe_relay and :paginator.
It provides the function `from_paginator/4` and `from_paginator/5` that work similarly to
`Absinthe.Relay.Connection.from_query/4` but takes Paginators' `paginate/3` instead of a
repo function. `from_paginator/4` also takes care of converting the Paginator page struct
to a Absinthe.Relay-style connection struct.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_paginator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_paginator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_paginator](https://hexdocs.pm/absinthe_paginator).
