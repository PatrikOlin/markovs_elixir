defmodule MarkovsElixir.Tokenizer do
    def tokenize(text) do
        text 
            |> String.downcase
            |> String.split(~r{\n}, trim: true) # split text to sentences
            |> Enum.map(&String.split/1) # split sentences to words
    end
end