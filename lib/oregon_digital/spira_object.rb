class OregonDigital::SpiraObject < Spira::Base

  def self.repository
    @repository ||= RDF::Repository.new
  end

  def initialize(*args)
    @content = args.first.delete(:content)
    populate_content! if @content
    super
  end

  def reader
    RDF::NTriples::Reader
  end

  private

  def populate_content!
    self.class.repository << reader.new(@content)
  end

end
