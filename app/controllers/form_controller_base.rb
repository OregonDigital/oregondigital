# Common elements needed for the form-manipulating controllers (ingest and template)
class FormControllerBase < ApplicationController
  before_filter :build_controlled_vocabulary_map

  protected

  # Method defines what the ingest form object's structure will look like when
  # converting the controller's asset into a form (asset_class) - must be
  # implemented by the subclass in order for other methods to work
  def asset_map
    raise NotImplementedError
  end

  # Asset class used to instantiate a new object or load an existing one -
  # must be implemented by the subclass for setup_resources
  def asset_class
    raise NotImplementedError
  end

  # Path to the index for validate_and_save's redirect - must be implemented by
  # the subclass
  def index_path
    raise NotImplementedError
  end

  # Attempts to save the asset, merging errors with the ingest form since the
  # form elements aren't mapped 1:1 to the asset fields. (type + value +
  # internal represent a single property).
  #
  # Note that fedora object errors won't necessarily make sense to the form if
  # they're too low-level, so custom validations should be carefully worded.
  def validate_and_save(success_message, failure_template)
    unless @form.valid?
      render failure_template
      return
    end

    @form.save

    if @form.has_cloned_associations?
      @form = @form.clone_associations
      flash.now[:notice] = success_message
      render :new
      return
    end

    redirect_to index_path, :notice => success_message
  end

  # Iterates over the ingest map, and looks up properties in the datastream
  # definition to see where we need controlled vocab and what the URL will be
  def build_controlled_vocabulary_map
    @controlled_vocab_map = {}

    for group, type_map in asset_map
      @controlled_vocab_map[group.to_s] = {}
      for type, attribute in type_map
        # We are assuming that a new-style datastream is going to be the final
        # object in the type-to-attribute value (i.e., in "foo.bar.baz", bar is
        # datastream, baz is attribute).  With this assumption we can pull the
        # property definition to see if a class is registered, and if so,
        # figure out how to set up a controlled vocabulary query URI.
        objects = attribute.to_s.split(".")
        attribute = objects.pop
        property = objects.reduce(asset_class.new, :send).class.properties[attribute]

        # TODO: What does it mean if we have no property for a mapped
        # attribute?  Likely a misconfiguration that the user cannot control.
        # We should send an error report somewhere here and silently move on,
        # as a browser error isn't going to be particularly useful :-/
        unless property
          raise "Invalid attribute while building controlled vocabulary map: group => " +
                "#{group.inspect}, type => #{type.inspect}, attribute => #{attribute.inspect}"
        end

        # Without a class, the data is simple and not something we try to
        # translate in any way
        next unless property[:class_name]

        # This is ugly - maybe we should have something more directly exposing the QA-friendly vocab parameter
        # (or create a map of param-to-class that each controlled vocab class registers and exposes)
        qa_class = property[:class_name].qa_interface.class
        vocab_param = qa_class.to_s.sub(/^OregonDigital::ControlledVocabularies::/, "")
        next if vocab_param.blank?

        path = qa.search_path(:vocab => vocab_param, :q => "VOCABQUERY")
        @controlled_vocab_map[group.to_s][type.to_s] = path
      end
    end
  end
end
