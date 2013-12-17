# This file generated automatically using vocab-fetch from http://dublincore.org/2012/06/14/dctype.rdf
require 'rdf'
module OregonDigital::Vocabularies
  class DCMITYPE < ::RDF::StrictVocabulary("http://purl.org/dc/dcmitype/")

    # Class definitions
    property :Collection, :label => 'Collection', :comment =>
      %(An aggregation of resources.)
    property :Dataset, :label => 'Dataset', :comment =>
      %(Data encoded in a defined structure.)
    property :Event, :label => 'Event', :comment =>
      %(A non-persistent, time-based occurrence.)
    property :Image, :label => 'Image', :comment =>
      %(A visual representation other than text.)
    property :InteractiveResource, :label => 'Interactive Resource', :comment =>
      %(A resource requiring interaction from the user to be
        understood, executed, or experienced.)
    property :MovingImage, :label => 'Moving Image', :comment =>
      %(A series of visual representations imparting an impression of
        motion when shown in succession.)
    property :PhysicalObject, :label => 'Physical Object', :comment =>
      %(An inanimate, three-dimensional object or substance.)
    property :Service, :label => 'Service', :comment =>
      %(A system that provides one or more functions.)
    property :Software, :label => 'Software', :comment =>
      %(A computer program in source or compiled form.)
    property :Sound, :label => 'Sound', :comment =>
      %(A resource primarily intended to be heard.)
    property :StillImage, :label => 'Still Image', :comment =>
      %(A static visual representation.)
    property :Text, :label => 'Text', :comment =>
      %(A resource consisting primarily of words for reading.)

    # Other terms
  end
end
