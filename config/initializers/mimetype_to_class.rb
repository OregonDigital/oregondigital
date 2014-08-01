ASSET_CLASS_LOOKUP = {
  %r|\Aimage/.*| => Image,
  "application/pdf" => Document,
  "application/ogg" => Audio,
  %r|\Aaudio/.*| => Audio,
  %r|\Avideo/.*| => Video
}
