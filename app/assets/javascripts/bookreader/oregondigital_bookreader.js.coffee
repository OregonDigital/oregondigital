jQuery ->
  window.BookReaderManager = new BookReaderManager
class BookReaderManager
  constructor: ->
    return unless $("#BookReader").length > 0
    @element = $("#BookReader")
    this.get_metadata($.proxy(this.initialize_bookreader, this))
    $('#BRtoolbar').find('.read').hide()
    $('#textSrch').hide()
    $('#btnSrch').hide()
  get_metadata: (callback) ->
    pid = @element.data("pid")
    $.getJSON("/document/#{pid}.json", (data) =>
      @page_info = data["pages"]
      callback()
    )
  initialize_bookreader: ->
    @br = new BookReader()
    @br.imagesBaseURL = "/assets/bookreader/images/"
    @br.getPageWidth = (index) => @page_info[index]["size"]["width"]
    @br.getPageHeight = (index) => @page_info[index]["size"]["height"]
    @br.getPageURI = this.getPageURI
    @br.getPageSide = this.getPageSide
    @br.getSpreadIndices = this.getSpreadIndices
    @br.getPageNum = (index) -> index+1
    @br.numLeafs = @page_info.length
    @br.bookTitle = @element.data("title")
    @br.bookUrl = ''
    @br.getEmbedCode = -> return "Embedding is disabled."
    @br.init()
    return @br
  getPageURI: (index, reduce, rotate) =>
    "#{@element.data("root")}/page-#{index+1}.png"
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
