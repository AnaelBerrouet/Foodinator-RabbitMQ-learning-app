defmodule Foodinator.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false

  alias Foodinator.Repo
  alias Foodinator.Orders.Order
  alias Foodinator.Orders.Message
  alias Foodinator.Queues.Publisher

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order) |> Repo.preload(:restaurant)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id) |> Repo.preload(:restaurant)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{status: "initiated"}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def send_order_request(%Order{} = order) do
    message = Message.request(order)

    Publisher.publish_message(message, message.topic)
  end

  def send_order_confirmation(%Order{} = order) do
    message = Message.confirm(order)

    Publisher.publish_message(message, message.topic)
  end

  def send_order_rejection(%Order{} = order) do
    message = Message.reject(order)

    Publisher.publish_message(message, message.topic)
  end

  def send_cancelation_acknowledgement(%Order{} = order) do
    message = Message.ackowledge_cancelation(order)

    Publisher.publish_message(message, message.topic)
  end

  def send_order_ready(%Order{} = order) do
    message = Message.ready(order)

    Publisher.publish_message(message, message.topic)
  end
end
