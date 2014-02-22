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
  },

  subject: {
    subject: "descMetadata.subject",
  },

  type: {
    type: "descMetadata.type",
  },

  format: {
    format: "descMetadata.format",
  },

  date: {
    created: "descMetadata.created",
    modified: "descMetadata.modified",
    date: "descMetadata.date",
  },

  description: {
    description: "descMetadata.description"
  },

  grouping: {
    set: "descMetadata.set"
  },

  identifier: {
    identifier: "descMetadata.identifier",
  },

  right: {
    rights: "descMetadata.rights"
  },

  publisher: {
  },

  administrative: {
  },

  geographic: {
    location: "descMetadata.location",
  },
}

# Temporary hack to verify separation of maps works
TEMPLATE_MAP = INGEST_MAP
