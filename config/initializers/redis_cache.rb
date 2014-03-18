class Redis

  def cache(key, expire=nil)
    result = get(key)
    return result unless result.nil?
    result = yield(self)
    set(key, result)
    expire(key, expire) if expire
    result
  end

end
