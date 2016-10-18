#!/usr/bin/env bash
#
# Syncs data from github for set content.  Meant to be run as part of an image
# build; use the rake task to resync if necessary.
REPO_PATH="/opt/od_set_content"
GITFILE="$REPO_PATH/.git"

gitclone() {
  /usr/bin/git clone https://github.com/OregonDigital/oregon-digital-set-content.git $REPO_PATH
}

if [[ ! -d $GITFILE ]]; then
  gitclone
fi
