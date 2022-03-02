# Creates an image suitable for running the Rails stack for OD 1
#
# Build:
#     docker build --rm -t oregondigital/od1 -f docker/Dockerfile .

# TODO: Upgrade ubuntu!  Right now this just needs to work with what we have in
# circleci, but longer-term this could get problematic when ubuntu 12 hits EOL.
#
# Known issues:
# - VIPS install will need to be figured out for a newer Ubuntu
# - Will need to test derivative generation for all types since CLI changes sometimes happen
# - ffmpeg will need to be replaced, and libavcode-extra-53 definitely has to be replaced
FROM ubuntu:16.04
MAINTAINER Jeremy Echols <jechols@uoregon.edu>

#apt won't find some libs if this isn't run
RUN apt-get update --fix-missing && apt-get install -y pkg-config \
  python-software-properties software-properties-common automake \
  build-essential gtk-doc-tools libglib2.0-dev libjpeg-turbo8-dev libpng12-dev \
  libwebp-dev libtiff5-dev libexif-dev libgsf-1-dev liblcms2-dev libxml2-dev \
  swig libmagickcore-dev curl && mkdir -p /opt/libvips

# Vips!
#RUN apt-get install -y automake build-essential \
#                       gtk-doc-tools libglib2.0-dev \
#                       libjpeg-turbo8-dev libpng12-dev libwebp-dev libtiff5-dev libexif-dev \
#                       libgsf-1-dev liblcms2-dev libxml2-dev swig libmagickcore-dev curl

WORKDIR /opt/libvips
RUN curl -L https://github.com/libvips/libvips/releases/download/v8.6.3/vips-8.6.3.tar.gz | tar zx
WORKDIR /opt/libvips/vips-8.6.3
RUN ./configure --enable-debug=no --enable-docs=no --enable-cxx=yes --without-python --without-orc --without-fftw && make && make install && ldconfig

# Various derivative libs
RUN apt-get purge libreoffice* && add-apt-repository -y ppa:libreoffice/ppa &&\
  apt-get install -y poppler-utils poppler-data ghostscript libreoffice \
  libmagic-dev libmagickwand-dev ffmpeg libavcodec-ffmpeg-extra56 \
  libvorbis-dev graphicsmagick graphicsmagick-libmagick-dev-compat \
  libmysqlclient-dev libsqlite3-dev nodejs git tzdata libssl-dev \
  libreadline-dev

# Grab Ruby manually - can't install the default for Ubuntu 12.04
#
# Make sure this comes after the big downloads, as it's more likely we'll
# change our ruby version than, say, our vips version - at least until we deal
# with a major change (like OS) that would require a ruby rebuild anyway
RUN  mkdir -p /opt/ruby
WORKDIR /opt/ruby
RUN curl https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.8.tar.gz | tar zx
WORKDIR /opt/ruby/ruby-2.3.8
RUN ./configure && make && make install && gem install bundler -v '1.17.3'

# Set an environment variable to store where the app is installed to inside
# of the Docker image
ENV INSTALL_PATH /oregondigital
WORKDIR $INSTALL_PATH

# Pull down set content first so code updates, which are more common than set
# updates, don't re-run the set syncing process
COPY docker/sync-sets.sh /sync-sets.sh
RUN chmod +x /sync-sets.sh && /sync-sets.sh

# Grab the current code from github so we can use this directly or overlay our
# own code on top of it - this makes it close to a production image *and*
# ensures that changes to things like Gemfile and Gemfile.lock don't re-pull
# the entire list of gems
RUN cd / && git clone --depth 1 https://github.com/OregonDigital/oregondigital.git $INSTALL_PATH

# Install gems

RUN bash -lc 'PATH="/usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16:$PATH"\
  gem install rmagick -v "2.13.2"' && bundle install --without development test\
  && bundle update --source=mysql2 --major && \
  ln -s /opt/od_set_content /oregondigital/set_content

# Link the set content repo inside OD
COPY docker/entrypoint.sh /entrypoint.sh
# /entrypoint.sh can be overwritten, but provides basic default behavior of
# running the web server
COPY docker/link-set-content.sh /link-set-content.sh
RUN chmod +x /link-set-content.sh && /link-set-content.sh && bundle exec \
  rake tmp:create && mkdir -p /oregondigital/media/thumbnails && \
  ln -s /oregondigital/media /oregondigital/public/media && \
  ln -s /oregondigital/media/thumbnails /oregondigital/public/thumbnails && \
  chmod +x /entrypoint.sh
  

# Expose a volume so that the web server can read assets
VOLUME ["$INSTALL_PATH/public"]

# Allow devs to override the app code entirely
VOLUME ["$INSTALL_PATH/"]

ENTRYPOINT ["/entrypoint.sh"]
