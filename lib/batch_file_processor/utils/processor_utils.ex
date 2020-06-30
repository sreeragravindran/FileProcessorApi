defmodule BatchFileProcessor.Utils.ProcessorUtils do
    @moduledoc """
        Utils file to get configured details regarding
        each processors and the modules
    """
    def get_module(processor) do
        case processor do
            "word_count" ->
                BatchFileProcessor.Processors.WordCountProcessor
            _ ->
                :invalid_processor
        end
    end

    def get_processing_dir(processor) do
        case processor do
            "word_count" ->
                "/opt/sampleBatchFiles/wordCount/"
            _ ->
                :invalid_processor
        end
    end


end