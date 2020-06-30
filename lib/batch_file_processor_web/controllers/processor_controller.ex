defmodule BatchFileProcessorWeb.ProcessorController do
    use BatchFileProcessorWeb, :controller
    alias BatchFileProcessor.Components.ProcessorHandler
    alias BatchFileProcessor.Repositories.Processor
    alias BatchFileProcessor.Utils.FilterNil
  
    def index(conn, _params) do
      json(conn |> put_status(200), "Processor Endpoint active")
    end

    def process_files(conn, %{"processor" => processor}) do
        {:ok, reply} = ProcessorHandler.start_processor(processor) |> IO.inspect()
        json(
            conn |> put_status(200),
            reply
          )
    end

    def get_status(conn, %{"processor" => processor}) do
        case Processor.get_processor(:by_name, processor) do
            nil ->
                json(conn |> put_status(200),"No active Process")                
            processor ->
                json(conn |> put_status(200), FilterNil.get_map_without_nil_values(processor))
        end
    end
  end
  