defmodule BatchFileProcessor.Schemas.Files do
    @moduledoc """
        Schema for storing all possible counters 
        when processing a file
    """
    use Ecto.Schema
    import Ecto.Changeset
    require Logger

    @primary_key false
    embedded_schema do
        field :name, :string
        field :total_records, :integer
        field :successfully_processed, :integer
        field :failed_to_process, :integer
    end
end