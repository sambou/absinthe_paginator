{:ok, _pid} = AbsinthePaginatorTest.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(AbsinthePaginatorTest.Repo, :manual)

ExUnit.start()
