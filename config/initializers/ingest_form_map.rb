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
    title: :title,
  },

  subject: {
    subject: :subject,
  },

  type: {
    type: :type,
  },

  format: {
    hasFormat: :hasFormat,
  },

  date: {
    created: :created,
    modified: :modified,
    date: :date,
  },

  description: {
    description: :description
  },

  grouping: {
    set: :set
  },

  identifier: {
    identifier: :identifier,
  },

  right: {
    rights: :rights
  },

  publisher: {
  },

  administrative: {
  },

  geographic: {
    location: :location,
  },
}
