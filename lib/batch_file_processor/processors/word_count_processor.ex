defmodule BatchFileProcessor.Processors.WordCountProcessor do
    @moduledoc """
        A sample file processor which counts the occurence of each word
        in the file.
    """

    alias BatchFileProcessor.Utils.ProcessorUtils
    alias alias BatchFileProcessor.Repositories.Processor

    def start(pid) do
        IO.inspect "In Start"
        processDir = ProcessorUtils.get_processing_dir("word_count")
        {:ok, files} = File.ls(processDir) |> IO.inspect()
        counter_ref = :counters.new(3, [:write_concurrency])
        update_total_count(pid, processDir, files, counter_ref)
        files
        |> Enum.each(fn file -> 
            count_each_word(pid, processDir <> file, counter_ref)
        end)
    end
    
    def count_each_word(pid, filePath, counter_ref) do
        File.stream!(filePath)
            |> Flow.from_enumerable()
            |> Flow.flat_map(&String.split(&1, [" ", "\n"]))
            |> Flow.partition()
            |> Flow.reduce(fn -> %{} end, fn word, acc ->
                if word != "" do
                    :counters.add(counter_ref, 2, 1)
                    Map.update(acc, word, 1, & &1 + 1)
                else
                    acc
                end
                end)
            |> Enum.to_list()
        IO.inspect(:counters.get(counter_ref, 2))
        Processor.update_processor(pid, %{
            :successfully_processed => :counters.get(counter_ref, 2),
            :end_date_time => DateTime.utc_now() |> DateTime.to_iso8601()
        })
    end

    def update_total_count(pid, processDir, files, counter_ref) do
        IO.inspect "getting total count"
        Enum.each(files, fn file -> 
            filePath = processDir <> file
            IO.inspect filePath
            File.stream!(filePath)
            |> Flow.from_enumerable()
            |> Flow.map(&String.trim(&1, "\n"))
            |> Flow.partition()
            |> Flow.reduce(fn -> %{} end, fn x, acc -> 
                :counters.add(counter_ref, 1, 1)
                acc
            end)
            |> Enum.to_list()
        end)
        
        IO.inspect("count complete")
        IO.inspect :counters.get(counter_ref, 1)

        Processor.update_processor(pid, %{
            :files => files,
            :total_records => :counters.get(counter_ref, 1),
            :successfully_processed => 0,
            :failed_to_process => 0
            })
    end
end