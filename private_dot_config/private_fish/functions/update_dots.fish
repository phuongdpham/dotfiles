function update_dots
    if test (count $argv) -eq 0
        echo "Usage: update_dots 'your commit message'"
        return 1
    end

    chezmoi git -- add .
    chezmoi git -- commit -m "$argv"
    chezmoi git -- push

    echo "Dotfiles updated and pushed to GitHub!"
end
