defmodule AbsinthePaginator do
  @moduledoc """
  AbsinthePaginator helps connecting the packages :absinthe_relay and :paginator.
  It provides the function `from_paginator/4` and `from_paginator/5` that work similarly to
  `Absinthe.Relay.Connection.from_query/4` but takes Paginators' `paginate/3` instead of a
  repo function. `from_paginator/4` also takes care of converting the Paginator page struct
  to a Absinthe.Relay-style connection struct.
  """

  @spec from_paginator(
          Ecto.Query.t(),
          (Ecto.Query.t(), Keyword.t(), Keyword.t() -> Paginator.Page.t()),
          Absinthe.Relay.Connection.Options.t(),
          Keyword.t(),
          Keyword.t()
        ) ::
          {:ok, AbsintheRelay.Connection.t()}
  def from_paginator(query, paginate, args, opts, repo_opts \\ [])

  def from_paginator(query, paginate, %{first: limit, after: cursor}, opts, repo_opts) do
    args = Keyword.merge(opts, after: cursor, limit: limit)

    query
    |> paginate.(args, repo_opts)
    |> to_relay_connection(args, dir: :forward)
  end

  def from_paginator(query, paginate, %{first: limit}, opts, repo_opts) do
    args = Keyword.merge(opts, limit: limit)

    query
    |> paginate.(args, repo_opts)
    |> to_relay_connection(args, dir: :forward)
  end

  def from_paginator(query, paginate, %{last: limit, before: cursor}, opts, repo_opts) do
    args = Keyword.merge(opts, after: cursor, limit: limit)

    query
    |> paginate.(args, repo_opts)
    |> to_relay_connection(args, dir: :backward)
  end

  def from_paginator(query, paginate, %{last: limit}, opts, repo_opts) do
    args = Keyword.merge(opts, limit: limit)

    query
    |> paginate.(args, repo_opts)
    |> to_relay_connection(args, dir: :backward)
  end

  defp to_relay_connection(
         %Paginator.Page{entries: entries, metadata: metadata},
         opts,
         relay_opts
       ) do
    edges =
      entries
      |> Enum.map(fn entry ->
        %{
          cursor: Paginator.cursor_for_record(entry, opts[:cursor_fields]),
          node: entry
        }
      end)

    page_info = %{
      start_cursor: nil,
      end_cursor: nil,
      has_previous_page:
        if(relay_opts[:dir] == :backward,
          do: not is_nil(metadata.after),
          else: false
        ),
      has_next_page:
        if(relay_opts[:dir] == :forward,
          do: not is_nil(metadata.after),
          else: false
        )
    }

    {:ok,
     %{
       edges:
         if(relay_opts[:dir] == :backward,
           do: Enum.reverse(edges),
           else: edges
         ),
       page_info: page_info
     }}
  end
end
