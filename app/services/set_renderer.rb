class SetRenderer
  attr_accessor :set, :lookup_context, :set
  def initialize(set, lookup_context, params={})
    @set, @lookup_context, @params = [set, lookup_context, params]
  end
  def partial_name
    return template_name if lookup_context.template_exists?(template_name)
    return generic_index
  end

  private

  def generic_index
    "sets/generic/index"
  end

  def set_name
    @set_name ||= OregonDigital::IdService.noidify(set.pid)
  end

  def template_name
    "sets/#{set_name}/#{page_name}"
  end

  def page_name
    "index"
  end
end