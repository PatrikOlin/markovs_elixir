defmodule MarkovsElixir.Model do
    import MarkovsElixir.Tokenizer

    def start_link, do: Agent.start_link(fn -> %{} end) # create map for sharing through agent

    def populate(pid, text) do
        for tokens <- tokenize(text), do: modelize(pid, tokens) # populate model with tokens
        pid
    end
    
    def fetch_token(state, pid) do
        tokens = fetch_tokens state, pid

        if length(tokens) > 0 do
            token = Enum.random tokens
            count = tokens |> Enum.count(&(token == &1))
            {token, count / length(tokens)} # count probability of the token
        else
            {"", 0.0}
        end
    end

    def fetch_state(tokens), do: fetch_state(tokens, length(tokens))
    defp fetch_state(_tokens, id) when id == 0, do: {nil, nil}
    defp fetch_state([head | _tail], id) when id == 1, do: {nil, head}
    defp fetch_state(tokens, id) do
        tokens
            |> Enum.slice(id - 2..id - 1) # fetch states by id
            |> List.to_tuple
    end

    # Get tokens within agent
    defp fetch_tokens(state, pid), do: Agent.get pid, &(&1[state] || [])

    # Build markov chain model using tokens
    defp modelize(pid, tokens) do
        for {token, id} <- Enum.with_index(tokens) do
            tokens |> fetch_state(id) |> add_state(pid, token)
        end
    end

    # Add new state within agent
    defp add_state(state, pid, token) do
        Agent.update pid, fn(model) -> 
            current_state = model[state] || []
            Map.put model, state, [token | current_state]
        end
    end
end