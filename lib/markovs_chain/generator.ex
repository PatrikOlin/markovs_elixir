defmodule MarkovsElixir.Generator do
    alias MarkovsElixir.Model

    def create_sentence(pid) do
        {sentence, prob} = build_sentence(pid)

        #create new sentence or convert bilded based on threshold value
        if prob >= Application.get_env(:markovs_elixir, :threshold) do
            sentence |> Enum.join(" ") |> String.capitalize
        else
            create_sentence pid
        end
    end

    # sentence is complete when it have enough length
    # or when punctuaioin ends a sentence
    defp complete?(tokens) do
        length(tokens) > 35 ||
        (length(tokens) > 15 && Regex.match?(~r/[\!\?\.]\z/, List.last tokens)) 
    end

    defp build_sentence(pid), do: build_sentence(pid, [], 0.0, 0.0)
    defp build_sentence(pid, tokens, prob_acc, new_tokens) do
        # fetch Markov model state through agent
        {token, prob} = tokens |> Model.fetch_state |> Model.fetch_token(pid)

        case complete?(tokens) do
            true ->
                score = case new_tokens == 0 do
                    true -> 1.0
                    _ -> prob_acc / new_tokens #count new probability for this word
                end
                {tokens, score}
            _ -> 
                # concat sentence with new token and try to continue
                build_sentence pid, tokens ++ [token], prob + prob_acc, new_tokens + 1 
        end
    end
end