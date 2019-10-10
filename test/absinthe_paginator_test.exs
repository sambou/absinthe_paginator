defmodule AbsinthePaginatorTest do
  use ExUnit.Case
  doctest AbsinthePaginator

  import Ecto.Query

  alias AbsinthePaginatorTest.{Repo, Item}
  import AbsinthePaginator, only: [from_paginator: 4]

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    {:ok, i1} = Repo.insert(%Item{title: "c"})
    {:ok, i2} = Repo.insert(%Item{title: "e"})
    {:ok, i3} = Repo.insert(%Item{title: "g"})

    {:ok, items: [i1, i2, i3]}
  end

  test "forward pagination", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [asc: i.title])
    args = [cursor_fields: [:title]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{first: 2}, args)

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{first: 2, after: last_cursor(page1)}, args)

    assert page1.page_info.has_next_page == true
    assert page1.edges == [edge(i1, args), edge(i2, args)]

    assert page2.page_info.has_next_page == false
    assert page2.edges == [edge(i3, args)]
  end

  test "forward pagination with deletes", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [asc: i.title])
    args = [cursor_fields: [:title]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{first: 1}, args)

    Repo.delete(i2)

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{first: 2, after: last_cursor(page1)}, args)

    assert page1.page_info.has_next_page == true
    assert page1.edges == [edge(i1, args)]

    assert page2.page_info.has_next_page == false
    assert page2.edges == [edge(i3, args)]
  end

  test "forward pagination with inserts", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [asc: i.title])
    args = [cursor_fields: [:title]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{first: 1}, args)

    {:ok, i4} = Repo.insert(%Item{title: "d"})

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{first: 3, after: last_cursor(page1)}, args)

    assert page1.page_info.has_next_page == true
    assert page1.edges == [edge(i1, args)]

    assert page2.page_info.has_next_page == false
    assert page2.edges == [edge(i4, args), edge(i2, args), edge(i3, args)]
  end

  test "backward pagination", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [desc: i.title])
    args = [sorting_direction: :desc, cursor_fields: [title: :desc]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{last: 2}, args)

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{last: 2, before: first_cursor(page1)}, args)

    assert page1.edges == [edge(i2, args), edge(i3, args)]
    assert page1.page_info.has_previous_page == true
    assert page2.edges == [edge(i1, args)]
    assert page2.page_info.has_previous_page == false
  end

  test "backward pagination with deletes", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [desc: i.title])
    args = [sorting_direction: :desc, cursor_fields: [title: :desc]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{last: 2}, args)
    Repo.delete(i3)

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{last: 2, before: first_cursor(page1)}, args)

    assert page1.edges == [edge(i2, args), edge(i3, args)]
    assert page1.page_info.has_previous_page == true
    assert page2.edges == [edge(i1, args)]
    assert page2.page_info.has_previous_page == false
  end

  test "backward pagination with inserts", %{items: [i1, i2, i3]} do
    query = from(i in Item, order_by: [desc: i.title])
    args = [sorting_direction: :desc, cursor_fields: [title: :desc]]

    {:ok, page1} = from_paginator(query, &Repo.paginate/3, %{last: 2}, args)
    {:ok, i4} = Repo.insert(%Item{title: "d"})

    {:ok, page2} =
      from_paginator(query, &Repo.paginate/3, %{last: 2, before: first_cursor(page1)}, args)

    assert page1.edges == [edge(i2, args), edge(i3, args)]
    assert page1.page_info.has_previous_page == true
    assert page2.edges == [edge(i1, args), edge(i4, args)]
    assert page2.page_info.has_previous_page == false
  end

  defp last_cursor(conn), do: List.last(conn.edges).cursor
  defp first_cursor(conn), do: List.first(conn.edges).cursor

  defp edge(item, args),
    do: %{cursor: Paginator.cursor_for_record(item, args[:cursor_fields]), node: item}
end
