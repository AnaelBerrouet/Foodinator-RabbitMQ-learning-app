# Foodinator

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

#### Order State Machine
  - statuses: [`:initiated`, `:confirmed`, `:processing`, `:ready`, `:rejected`, `:canceled`]
  - transistions:
    [
      `:initiated` ->
        `confirmed:` "Order is acknowledged/accepted by restaurant"
        `rejected:` "Order is rejected by restaurant"
        `canceled:` "Order is canceled by customer"
      `:confirmed` ->
        `processing:` "Order is being prepared by restaurant"
        `canceled:` "Order is canceled by customer"
      `:processing` ->
        `ready:` "Order has stated ready for pickup"
        `canceled:` "Order is canceled by customer with payment"
      `:ready` -> `terminal`
      `:rejected` -> `terminal`
      `:canceled` -> `terminal`

#### Creating schemas
mix phx.gen.live Restaurants Restaurant restaurants name:string logo:string items:map
mix phx.gen.live Orders Order orders name:string address:string restaurant_id:references:restaurants item:integer status:string
mix phx.gen.live Events Event events process:string action:string order_id:references:orders

#### Notes
- Should [install](https://clickhouse.com/docs/en/install) clickhouse binary for client and server
- Clickhouse RabbitMQ [docs](https://clickhouse.com/docs/en/engines/table-engines/integrations/rabbitmq)
- Clickhouse [Docker image](https://hub.docker.com/r/clickhouse/clickhouse-server)
- Reference github [project](https://github.com/pachico/demo-clickhouse-rabbitmq-engine)