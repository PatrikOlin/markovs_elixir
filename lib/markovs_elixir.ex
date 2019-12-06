defmodule MarkovsElixir do
  alias MarkovsElixir.Model
  alias MarkovsElixir.Generator

  def start(_type, _args) do
    case File.read(Application.get_env :markovs_elixir, :source_file) do
      {:ok, body} -> process_source body
      {:error, reason} -> IO.puts reason
    end

    System.halt 0
  end

  defp process_source(text) do
    {:ok, model} = Model.start_link
    model = Model.populate model, text # populate markov model with the source

    # generate 10 random sentences based on text source
    Enum.each(1..10, fn(_) -> model |> Generator.create_sentence |> IO.puts end)
    
  end
end
