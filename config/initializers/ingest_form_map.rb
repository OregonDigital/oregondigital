# TODO: Pull this data from an actual dynamic map of some sort!

# Legend for this data:
#
#     { group: { type: attribute } }
#
# - Groups are view-specific elements used solely to categorize similar fields
# - Types are view-specific elements that let the user choose what specific
#   data to fill out within a group
# - Each group can have any number of type-to-attribute maps
# - Each type maps directly to an attribute on the datastream
# - When a user enters data for a given group and type, the attribute lets
#   us know how to store the data
# - There is no check right now, but attributes should be unique - i.e., there
#   shouldn't be two different ways to edit the same field on a single form,
#   and likewise we shouldn't show the data twice on a show view
# - ORDER MATTERS - we're relying on the hash being ordered in order to let the
#   UI group things in a logical way as well as showing types in the given order
INGEST_MAP = {
  title: {
    title: "descMetadata.title",
    alternative: "descMetadata.alternative",
  },

  creator: {
    creator: "descMetadata.creator",
    contributor: "descMetadata.contributor",
    photographer: "descMetadata.photographer",
    illustrator: "descMetadata.illustrator",
  },
  
  description: {
    description: "descMetadata.description",
    abstract: "descMetadata.abstract",
    view: "descMetadata.view",
    culturalContext: "descMetadata.culturalContext",
    inscription: "descMetadata.inscription",
    cover: "descMetadata.cover",
  },

  subject: {
    lcsubject: "descMetadata.lcsubject",
  },
  
  geographic: {
    location: "descMetadata.location",
  },

  date: {
    created: "descMetadata.created",
    modified: "descMetadata.modified",
    date: "descMetadata.date",
    dateSubmitted: "descMetadata.submissionDate",
    issued: "descMetadata.issued",
    earliestDate: "descMetadata.earliestDate",
    latestDate: "descMetadata.latestDate",
  },

  identifier: {
    identifier: "descMetadata.identifier",
    locationCopyShelfLocator: "descMetadata.locationCopyShelfLocator",
  },

  right: {
    rights: "descMetadata.rights",
    copyrightClaimant: "descMetadata.copyrightClaimant",
  },

  publishing: {
    source: "descMetadata.source",
    language: "descMetadata.language",
    publisher: "descMetadata.publisher",
    placeOfPublication: "descMetadata.placeOfPublication",
    provenance: "descMetadata.provenance",
  },
  
  type: {
    type: "descMetadata.type",
    workType: "descMetadata.workType",
  },

  format: {
    format: "descMetadata.format",
    physicalExtent: "descMetadata.physicalExtent",
    measurements: "descMetadata.measurements",
    hasPart: "descMetadata.hasPart",
  },

  grouping: {
    set: "descMetadata.set",
    localCollection: "descMetadata.localCollection",
    exhibit: "descMetadata.exhibit",
  },

  administrative: {
    locationCopySublocation: "descMetadata.locationCopySublocation",
    institution: "descMetadata.institution",
    conversion: "descMetadata.conversion",
  },

}

# XXX HACK: we just duplicate and modify the INGEST_MAP data to ensure we're in
# sync.  But long-term, we may want a separate map that just has to be kept
# partially synced or something, so for now this is the quick fix.
#
# We use JSON to dup here because dup is shallow
TEMPLATE_MAP = JSON.load(INGEST_MAP.to_json)
for group, types_map in TEMPLATE_MAP
  for type, property in types_map
    property.gsub!("descMetadata", "templateMetadata")
  end
end
