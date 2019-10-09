defmodule AbsinthePaginatorTest.Repo.Migrations.AddTestItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add(:title, :string)
    end
  end
end
