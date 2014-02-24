jQuery ->
  window.SeaDragonManager = new SeaDragonManager
class SeaDragonManager
  constructor: ->
    @viewers = []
    this.create_viewers()
  create_viewers: ->
    m = this
    $('*[data-action=openseadragon]').each ->
      container = $(this)
      return if !container.attr("id")?
      console.log(container.attr("id"))
      viewer = OpenSeadragon({
        id: container.attr("id")
        prefixUrl: m.prefix
        tileSources: container.data("tileSource")
        constrainDuringPan: true
      })
      m.viewers << viewer
      return
  prefix: "/assets/openseadragon/"