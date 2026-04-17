#!/usr/bin/fish

function work
    set session personal-work

    # 1. Check if the session already exists
    tmux has-session -t $session 2>/dev/null

    if test $status != 0
        # 2. Create the session (detached) and the first window
        tmux new-session -d -s $session -n backend

        # 3. Create a HORIZONTAL split (Top/Bottom)
        # -v creates a vertical split (horizontal divider)
        # -p 30 sets the bottom pane to 30% of the height
        tmux split-window -v -p 30 -t $session:backend

        # 4. Create the second window
        tmux new-window -t $session -n logs

        # 5. Reset focus to the top pane (Pane 1)
        tmux select-window -t $session:backend
        tmux select-pane -t $session:backend.1
    end

    # 6. Smart Attachment (Avoid nesting)
    if test -n "$TMUX"
        tmux switch-client -t $session
    else
        tmux attach-session -t $session
    end
end
