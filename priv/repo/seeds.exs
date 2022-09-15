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
alias Foodinator.Orders.Order

# Create Restaurants
item1 = UUID.uuid4()

res1 =
  Foodinator.Repo.insert!(%Restaurant{
    name: "Anael's Burger Joint",
    logo:
      "https://c8.alamy.com/comp/2H6AEDN/creative-burger-logo-design-symbol-vector-illustration-2H6AEDN.jpg",
    items: %{item1 => "Burger", UUID.uuid4() => "CheeseBurger", UUID.uuid4() => "Fries"}
  })

Foodinator.Repo.insert!(%Restaurant{
  name: "The Hot Pot Spot",
  items: %{UUID.uuid4() => "Beeg Bulgogi", UUID.uuid4() => "Fried Prawns"}
})

# Create Orders
Foodinator.Repo.insert!(%Order{
  name: "The Hot Pot Spot",
  address: "123 Fake St.",
  restaurant_id: res1.id,
  item: item1,
  status: "ready"
})
