#ssh redpanda@172.20.5.120  -t "tmux new-session -s $1 || tmux attach-session -t $1"
#mosh redpanda@172.20.5.120 -- tmux attach -t 0 -d
mosh redpanda@172.20.5.120 -- tmux new-session -s $1 || tmux attach-session -t $1 -d

