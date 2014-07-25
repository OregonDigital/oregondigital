#!/bin/bash
SESSION=od

create_session() {
  tmux -2 new -d -s $SESSION
}

do_panes() {
  WINDOW=`tmux list-w | grep "(active)" | cut -d: -f1`
  PANE_COUNT=`tmux list-p -t $SESSION:$WINDOW | wc -l`

  if [ "$PANE_COUNT" -gt 1 ]; then
    WINDOW=`tmux list-w | grep "(active)" | cut -d: -f1`
  fi

  # Log pane: bottom of screen
  tmux split-window -v -p 20 -t $SESSION:$WINDOW.0

  # Command pane: right of vim window, 43% width
  tmux split-window -h -p 43 -t $SESSION:$WINDOW.0

  # Make *all* panes use the desired rvm
  tmux set-window-option -t $SESSION:$WINDOW synchronize-panes on
  #tmux send-keys -t $SESSION:$WINDOW "rvm use od" C-m
  tmux set-window-option -t $SESSION:$WINDOW synchronize-panes off

  # Specific commands
  tmux send-keys -t $SESSION:$WINDOW.0 "vim" C-m F6
  tmux send-keys -t $SESSION:$WINDOW.1 "rails s webrick" C-m

  # No jetty?  Run it!
  PROC=`ps -ef | grep jetty | grep -v grep | wc -l`
  if [ "$PROC" -eq 0 ]; then
    tmux send-keys -t $SESSION:$WINDOW.2 "bundle exec rake jetty:start" C-m
  fi
}

# Already in a tmux window?  Assume we just want a quick pane setup, skipping session stuff.
if [ -n "$TMUX" ]; then
  do_panes
  exit 0
fi

# Attach if session already exists
tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
  tmux -2 attach -t $SESSION
  exit 0
fi

# No tmux, no session, create and do panes
create_session
do_panes
tmux -2 attach -t $SESSION
