FROM ruby:2.3-onbuild

MAINTAINER Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)

RUN rake build
