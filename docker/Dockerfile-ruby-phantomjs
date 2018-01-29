FROM ubuntu:16.04
MAINTAINER Linda Sato <lsato@uoregon.edu>

#apt won't find some libs if this isn't run
RUN apt-get update

# Dependencies for vips installer
RUN apt-get install -y pkg-config
RUN apt-get install -y python-software-properties software-properties-common

# Vips!

RUN apt-get install -y automake build-essential libgirepository1.0-dev  \
                       gtk-doc-tools libglib2.0-dev \
                       libjpeg-turbo8-dev libpng12-dev libwebp-dev libtiff5-dev libexif-dev \
                       libgsf-1-dev liblcms2-dev libxml2-dev swig libmagickcore-dev curl

RUN  mkdir -p /opt/libvips
WORKDIR /opt/libvips
RUN curl -L https://github.com/jcupitt/libvips/releases/download/v8.4.6/vips-8.4.6.tar.gz | tar zx
WORKDIR /opt/libvips/vips-8.4.6
ENV GI_TYPELIB_PATH /usr/local/lib/girepository-1.0/
RUN ./configure --enable-debug=no --enable-docs=no --enable-cxx=yes --without-python --without-orc --without-fftw
RUN make
RUN make install
RUN ldconfig

# Various derivative libs
RUN apt-get purge libreoffice*
RUN  add-apt-repository -y ppa:libreoffice/ppa
RUN apt-get install -y poppler-utils poppler-data ghostscript libreoffice
RUN apt-get install -y libmagic-dev libmagickwand-dev ffmpeg libavcodec-ffmpeg-extra56 libvorbis-dev
RUN apt-get install -y graphicsmagick graphicsmagick-libmagick-dev-compat

# Database connection libraries
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y libsqlite3-dev

# Nodejs for compiling assets
RUN apt-get install -y nodejs

# We need git for all our github-hosted gems
RUN apt-get install -y git
# Rails requires this
RUN apt-get install -y tzdata

# Dependencies for Ruby
RUN apt-get install -y libssl-dev libreadline-dev

# Grab Ruby manually
#
# Make sure this comes after the big downloads, as it's more likely we'll
# change our ruby version than, say, our vips version - at least until we deal
# with a major change (like OS) that would require a ruby rebuild anyway
RUN  mkdir -p /opt/ruby
WORKDIR /opt/ruby
RUN curl https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz | tar zx
WORKDIR /opt/ruby/ruby-2.1.3
RUN ./configure
RUN make
RUN make install

# PhantomJS dependencies
RUN apt-get install -y g++ flex bison gperf perl \
   libfontconfig1-dev libicu-dev libfreetype6 \
  libpng-dev libx11-dev libxext-dev

RUN git clone https://github.com/ariya/phantomjs/ /opt/phantomjs
WORKDIR /opt/phantomjs
RUN git checkout 1.8.1
RUN yes | ./build.sh
