module OregonDigital
  module Collectible
    # This returns all collections referenced by the od:set value on the object.
    def collections(force_reload = false)
      return @collections if @collections && !force_reload
      # There should be a better way to find multiple IDs.
      # TODO: Make this piece better - newer versions of ActiveFEdora
      # have a built in way to do this. (Currently on AF 5.3.1)
      @collections = set.map { |x| GenericCollection.send(:find_one, x) }
      @collections
    end
  end
end
