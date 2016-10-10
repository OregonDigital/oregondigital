#!/usr/bin/env bash
#
# Syncs data from github for set content.  Meant to be run as part of an image
# build; use the rake task to resync if necessary.
PATH=/oregondigital
REPO_PATH="$PATH/set_content"
GITFILE="$REPO_PATH/.git"
ASSET_PATH="$PATH/app/assets"
SET_JS_PATH="$ASSET_PATH/javascripts/sets"
SET_IMG_PATH="$ASSET_PATH/images/sets"
SET_CSS_PATH="$ASSET_PATH/stylesheets/sets"
SET_CONTENT_PATH="$PATH/app/views/sets"

gitclone() {
  /usr/bin/git clone https://github.com/OregonDigital/oregon-digital-set-content.git $REPO_PATH
}

if [[ ! -d $GITFILE ]]; then
  gitclone
fi
