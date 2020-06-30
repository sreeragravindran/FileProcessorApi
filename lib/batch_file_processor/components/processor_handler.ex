defmodule BatchFileProcessor.Components.ProcessorHandler do
    use GenServer
    alias BatchFileProcessor.Repositories.Processor
    alias BatchFileProcessor.Utils.ProcessorUtils
  
    def start_link(opts \\ %{}), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    
    def init(_) do
        {:ok, %{:active_processors => 0}}
    end

    def start_processor(processor) do
      GenServer.call(__MODULE__, {:start_processor, processor})
    end
  
    def handle_call({:start_processor, processor}, _from, %{:active_processors => active} = state) do
      if Processor.get_active_process_id(processor) == nil do
        start_processing(processor)
        {:reply, {:ok, "Started Processing"}, %{:active_processors => active + 1}}
      else
        {:reply, {:ok, "Processor Running Already"}, state}
      end
    end
  
    # The task completed successfully
    def handle_info({ref, answer}, %{:active_processors => active}) do
      # We don't care about the DOWN message now, so let's demonitor and flush it
      Process.demonitor(ref, [:flush])
      Processor.get_process_by_ref(ref |> :erlang.ref_to_list() |> List.to_string())
      |> Processor.update_processor(%{:state => "completed"})
      {:noreply, %{:active_processors => active - 1}}
    end
  
    # The task failed
    def handle_info({:DOWN, ref, :process, _pid, _reason}, %{:active_processors => active}) do
      # Log and possibly restart the task...
      Process.demonitor(ref, [:flush])
      Processor.get_process_by_ref(ref |> :erlang.ref_to_list() |> List.to_string())
      |> Processor.update_processor(%{:state => "failed"})
      {:noreply, %{:active_processors => active - 1}}
    end

    def start_processing(processor) do
        module = ProcessorUtils.get_module(processor)
        {:ok, process} = Processor.add_processor(processor)
        task =
            Task.Supervisor.async_nolink(BatchFileProcessor.ProcessorSupervisor,  
            module, :start, [process.id])
        Processor.update_processor(process, %{
            :ref => task.ref |> :erlang.ref_to_list() |> List.to_string(),
            :start_date_time => DateTime.utc_now() |> DateTime.to_iso8601()
        })
    end
  end