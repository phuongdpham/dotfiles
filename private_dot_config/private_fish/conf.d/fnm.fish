# Config start fnm with fish
fish_add_path ~/.cargo/bin

if type -q fnm
    fnm env --use-on-cd --shell fish | source
end

