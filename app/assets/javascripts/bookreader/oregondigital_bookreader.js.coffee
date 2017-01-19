jQuery ->
  window.BookReaderManager = new BookReaderManager
class BookReaderManager
  constructor: ->
    return unless $("#BookReader").length > 0
    @element = $("#BookReader")
    this.get_metadata($.proxy(this.initialize_bookreader, this))
  get_metadata: (callback) ->
    pid = @element.data("pid")
    $.getJSON("/document/#{pid}.json", (data) =>
      @page_info = data["pages"]
      callback()
    )
  initialize_bookreader: =>
    @br = new BookReader()
    window.br = @br
    @br.imagesBaseURL = "/assets/bookreader/images/"
    @br.page_info = @page_info
    @br.getPageWidth = (index) -> @page_info[index]?["size"]?["width"]
    @br.getPageHeight = (index) -> @page_info[index]?["size"]?["height"]
    @br.getPageURI = this.getPageURI
    @br.getPageSide = this.getPageSide
    @br.getSpreadIndices = this.getSpreadIndices
    @br.getPageNum = (index) -> index+1
    @br.numLeafs = @page_info.length
    @br.bookTitle = @element.data("title")
    @br.bookId = @element.data("pid")
    @br.bookUrl = ''
    @br.getEmbedCode = -> return "Embedding is disabled."
    @br.reductionFactors = this.reductionFactors()
    @br.search_url = this.search_url
    @br.leafNumToIndex = (page) -> parseInt(page)-1
    @br.init()
    $('#BRtoolbar').find('.read').hide()
    #$('#textSrch').hide()
    #$('#btnSrch').hide()
    $('button.share').hide()
    $('button.info').hide()
    $('button.play').after('<button class="BRicon full" title="Fullscreen"></button><button class="BRicon return" title="Exit Fullscreen"></button>')
    $('button.return').hide()
    $('button.full').click( ->
      bookreader = document.getElementById('BookReader')
      rfs = bookreader.requestFullscreen || bookreader.msRequestFullscreen || bookreader.webkitRequestFullscreen || bookreader.mozRequestFullScreen
      rfs.call(bookreader)
    )
    $('button.return').click( ->
      efs = document.exitFullscreen || document.msExitFullscreen || document.webkitExitFullscreen || document.mozCancelFullScreen
      efs.call(document)
    )
    # add screen change event listeners for each of the specific browser types to toggle the show/hide buttons
    listeners = ['fullscreenchange', 'mozfullscreenchange', 'webkitfullscreenchange', 'msfullscreenchange']
    for listener in listeners
      document.addEventListener(listener, ->
        if document.fullscreenElement || document.msFullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
          $('button.full').hide()
          $('button.return').show()
        else
          $('button.return').hide()
          $('button.full').show()
      )
    return @br
  search_url: (term) =>
    "/document/#{@br.bookId}/fulltext/#{term.trim()}.json"
  reductionFactors: ->
    [ {reduce: 0.1, autofit: null},
     {reduce: 0.25, autofit: null},
      {reduce: 0.5, autofit: null},
        {reduce: 1, autofit: null},
        {reduce: 2, autofit: null},
        {reduce: 3, autofit: null},
        {reduce: 4, autofit: null},
        {reduce: 6, autofit: null} ];
  getPageURI: (index, reduce, rotate) =>
    reduce_factor = "small" if reduce >= 4
    reduce_factor ||= "normal" if reduce >= 2
    reduce_factor ||= "large" if reduce >= 1 
    reduce_factor ||= "x-large"
    "#{@element.data("root")}/#{reduce_factor}-page-#{index+1}.jpg"
  getPageSide: (index) ->
    if 0 == (index & 0x1)
      return'R'
    else
      return'L'
  getSpreadIndices: (pindex) =>
    spreadIndices = [null, null]
    if 'rl' == @br.pageProgression
      if this.getPageSide(pindex) == 'R'
        spreadIndices[1] = pindex
        spreadIndices[0] = pindex + 1
      else
        spreadIndices[0] = pindex
        spreadIndices[1] = pindex-1
    else
      if this.getPageSide(pindex) == 'L'
        spreadIndices[0] = pindex
        spreadIndices[1] = pindex + 1
      else
        spreadIndices[1] = pindex
        spreadIndices[0] = pindex-1
    return spreadIndices
