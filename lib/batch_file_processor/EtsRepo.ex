defmodule BatchFileProcessor.EtsRepo do
    use Ecto.Repo,
      otp_app: :batch_file_processor_test,
      adapter: Etso.Adapter
end
  