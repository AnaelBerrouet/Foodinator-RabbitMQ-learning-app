# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Foodinator.Repo.insert!(%Foodinator.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Foodinator.Restaurants.Restaurant

# Create Restaurants
item1 = UUID.uuid4()

Foodinator.Repo.insert!(%Restaurant{
  name: "Anael's Burger Joint",
  items: %{item1 => "Burger", UUID.uuid4() => "CheeseBurger", UUID.uuid4() => "Fries"}
})

Foodinator.Repo.insert!(%Restaurant{
  name: "The Hot Pot Spot",
  items: %{UUID.uuid4() => "Beef Bulgogi", UUID.uuid4() => "Fried Prawns"}
})

Foodinator.Repo.insert!(%Restaurant{
  name: "GetThru's Falafel House",
  items: %{UUID.uuid4() => "Falafel Bowl", UUID.uuid4() => "Falafel Wrap"}
})
