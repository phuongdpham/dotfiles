function fish_user_key_bindings
    # Vi key bindings
    fish_vi_key_bindings

    # VSCode terminal Alt+up and down
	bind --preset \e\[1\;5A _fzf_search_history
	bind --preset \e\[1\;5B _fzf_search_history
end
