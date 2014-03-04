jQuery ->
  window.BookReaderManager = new BookReaderManager
class BookReaderManager
  constructor: ->
    return unless $("#BookReader").length > 0
    @element = $("#BookReader")
    @br = this.initialize_bookreader()
    $('#BRtoolbar').find('.read').hide();
    $('#textSrch').hide();
    $('#btnSrch').hide();
  initialize_bookreader: ->
    @br = new BookReader()
    @br.imagesBaseURL = "/assets/bookreader/images/"
    @br.getPageWidth = (index) -> 1000
    @br.getPageHeight = (index) -> 1000
    @br.getPageURI = this.getPageURI
    @br.getPageSide = this.getPageSide
    @br.getSpreadIndices = this.getSpreadIndices
    @br.getPageNum = (index) -> index+1
    @br.numLeafs = @element.data("pages")
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
    spreadIndices = [null, null];
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
        spreadIndices[1] = pindex + 1;
      else
        spreadIndices[1] = pindex
        spreadIndices[0] = pindex-1
    return spreadIndices