find . \
  -name ".*.swp" -prune -o \
  -path ./braceros-tiffs -prune -o \
  -path ./tmp/ -prune -o \
  -path ./.git -prune -o \
  -path ./log -prune -o \
  -path ./jetty -prune -o \
  -path ./vendor/assets -prune -o \
  -path ./coverage -prune -o \
  -path ./tmp -prune -o \
  -type f -print | \
xargs grep --color "$1"
