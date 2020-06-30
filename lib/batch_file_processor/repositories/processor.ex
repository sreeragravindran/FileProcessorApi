defmodule BatchFileProcessor.Repositories.Processor do
    @moduledoc """
        Repository Layer for connecting to ETS table
        to add new processors, update existing processors
        or remove completed processors
    """
    alias BatchFileProcessor.EtsRepo
    import Ecto.Query
    alias BatchFileProcessor.Schemas.Processor

    def add_processor(name) do
        %Processor{}
        |> Processor.changeset(%{
            :name => name,
            :state => "active"
        })
        |> EtsRepo.insert()
    end

    def get_processor(:by_name, processor) do
        query = from p in Processor,
                where: p.name == ^processor,
                select: %{
                    name: p.name, 
                    state: p.state, 
                    start_date_time: p.start_date_time, 
                    end_date_time: p.end_date_time,
                    total_records: p.total_records,
                    files: p.files
                }
                
        EtsRepo.all(query)
    end

    def update_processor(%BatchFileProcessor.Schemas.Processor{} = processor, update_attrs) do
        IO.inspect "I'm here"
        IO.inspect update_attrs
        processor
        |> Processor.changeset(update_attrs)
        |> EtsRepo.update!()
    end

    def update_processor(processor_id, update_attrs) do
        IO.inspect "update attrs"
        IO.inspect update_attrs
        IO.inspect "update attrs"
        EtsRepo.get!(Processor, processor_id)
        |> Processor.changeset(update_attrs)
        |> EtsRepo.update!()
    end

    def get_active_process_id(name) do
        case EtsRepo.get_by(Processor, [name: name, state: "active"]) do
            nil ->
                nil
            processor ->
                processor.id
        end
    end

    def get_process_by_ref(ref) do
        EtsRepo.get_by!(Processor, ref: ref)
    end
end