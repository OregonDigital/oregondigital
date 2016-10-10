#!/usr/bin/env bash
#
# Creates symlinks to set content for views and assets
PATH=/oregondigital
REPO_PATH="$PATH/set_content"
GITFILE="$REPO_PATH/.git"
ASSET_PATH="$PATH/app/assets"
SET_JS_PATH="$ASSET_PATH/javascripts/sets"
SET_IMG_PATH="$ASSET_PATH/images/sets"
SET_CSS_PATH="$ASSET_PATH/stylesheets/sets"
SET_CONTENT_PATH="$PATH/app/views/sets"

/bin/mkdir -p $SET_JS_PATH
/bin/mkdir -p $SET_CSS_PATH
/bin/mkdir -p $SET_IMG_PATH
/bin/mkdir -p $SET_CONTENT_PATH

remove_symlinks() {
  /usr/bin/find $SET_JS_PATH -type l -exec rm {} \;
  /usr/bin/find $SET_CSS_PATH -type l -exec rm {} \;
  /usr/bin/find $SET_IMG_PATH -type l -exec rm {} \;
  /usr/bin/find $SET_CONTENT_PATH -type l -exec rm {} \;
}

create_symlinks() {
  for setdir in $(/usr/bin/find $REPO_PATH -maxdepth 1 -type d -not -name ".*"); do
    setname=${setdir##*/}

    dir=$setdir/content
    if [[ -d $dir ]]; then
      /bin/ln -s $dir $SET_CONTENT_PATH/$setname
    fi

    dir=$setdir/assets/javascripts
    if [[ -d $dir ]]; then
      /bin/ln -s $dir $SET_JS_PATH/$setname
    fi

    dir=$setdir/assets/images
    if [[ -d $dir ]]; then
      /bin/ln -s $dir $SET_IMG_PATH/$setname
    fi

    dir=$setdir/assets/stylesheets
    if [[ -d $dir ]]; then
      /bin/ln -s $dir $SET_CSS_PATH/$setname
    fi
  done
}

remove_symlinks
create_symlinks
