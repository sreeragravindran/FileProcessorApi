defmodule BatchFileProcessor.Schemas.Processor do
    @moduledoc """
        Schema for storing a Processor info in an ETS table
    """
    use Ecto.Schema
    import Ecto.Changeset
    require Logger
  
    @required [:name, :state]
    @optional [:ref, :files, :start_date_time, :end_date_time, :total_records, :successfully_processed]

    @derive {Jason.Encoder, only: [:name, :ref, :state]}
    @primary_key {:id, :binary_id, autogenerate: true}
    schema "processor" do
      field :name, :string
      field :ref, :string
      field :state, :string
      field :files, {:array, :string}
      field :start_date_time, :utc_datetime_usec
      field :end_date_time, :utc_datetime_usec
      field :total_records, :integer
      field :successfully_processed, :integer
      field :failed_to_process, :integer
    end

    def changeset(processor, attrs) do
        processor
        |> cast(attrs, @required ++ @optional)
        |> validate_required(@required)
    end

end