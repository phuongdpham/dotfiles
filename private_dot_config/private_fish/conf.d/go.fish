# Go envs
set -gx GOPATH $HOME/go
set -gx PATH $GOPATH/bin:$PATH
set -gx GOPRIVATE github.com/88labs
set -gx CGO_ENABLED 0

