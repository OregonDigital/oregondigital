class YamlDatastream < ActiveFedora::Datastream

  def content
    serialize
  end

  def content=(content)
    @inner_hash = deserialize(content)
  end

  def inner_hash
    @inner_hash ||= deserialize
  end

  def serialize
    serialization = inner_hash.to_h.stringify_keys
    serialization.blank? ? "" : serialization.to_yaml
  end

  def deserialize(data=nil)
    data ||= datastream_content
    data = YAML.load(data.to_s)
    data = RecursiveOpenStruct.new(data) if data.kind_of?(Hash)
    return data || RecursiveOpenStruct.new()
  end

  def serialize!
    @content = serialize
  end

  private

  # Delegate missing methods to the underlying hash.
  def method_missing(method, *args, &block)
    inner_hash.send(method, *args, &block)
  end

  def respond_to_missing?(method, include_private=false)
    super || delegatable?(method)
  end

  def delegatable?(method)
    inner_hash.respond_to?(method)
  end
end
