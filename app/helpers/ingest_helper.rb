module IngestHelper
  # Renders the ingest form for the given form object
  def ingest_form_for(form_container)
    ingest_form = form_container.form
    url = ingest_form_url(form_container)
    html_options = {:multipart => true, :class => "form-inline"}

    simple_form_for(ingest_form, {:url => url, :html => html_options}) do |f|
      yield(f)
    end
  end

  def ingest_form_url(form_container)
    if form_container.asset.kind_of?(Template)
      ingest_template_url(form_container.form)
    else
      ingest_generic_asset_url(form_container.form)
    end
  end

  def ingest_template_url(ingest_form)
    ingest_form.new_record? ? templates_path(ingest_form) : template_path(ingest_form)
  end

  def ingest_generic_asset_url(ingest_form)
    ingest_form.new_record? ? ingest_index_path(ingest_form) : ingest_path(ingest_form)
  end

  # Spits out all necessary fields for an ingest form "field group", adding
  # classes for styling and controlled vocab magic
  def type_value_fields(f)
    controls = []

    options_values = INGEST_MAP[f.object.group.to_sym].keys
    options = options_values.collect do |val|
      [OregonDigital::Metadata::FieldTypeLabel.for(val.to_s), val]
    end

    controls << f.input(
      :type,
      :collection => options,
      :input_html => {:class => "input-medium type-selector"},
      :label_html => {:class => "sr-only"},
      :wrapper_html => {:class => "ingest-control type"}
    )

    input_args = {
      :input_html => {:class => "input-xxlarge value-field"},
      :label_html => {:class => "sr-only"},
      :wrapper_html => {:class => "ingest-control value"}
    }

    # SUPER HACK!  If we're looking at sets, we don't want free-text, we want a
    # drop-down.  Ideally we'd have a nicer way to make any given type do this,
    # but the grouping dropdown makes it really tough without some painful new
    # configurable ingest map format combined with JavaScript that swaps a
    # dropdown over the text input magically
    if f.object.group.to_sym == :collection
      set_pids = ActiveFedora::SolrService.query(
        "has_model_ssim:#{RSolr.escape("info:fedora/afmodel:GenericCollection")}",
        :rows => 100000
      )
      prefix = "http://oregondigital.org/resource"
      set_options = set_pids.map do |pid|
        set = GenericCollection.load_instance_from_solr(pid["id"], pid)
        ["#{set.title} (#{set.pid})", "#{prefix}/#{set.pid}"]
      end

      input_args[:collection] = set_options.sort
      selected = f.object.value
      if selected.nil? || !selected.start_with?(prefix)
        selected = f.object.internal
      end
      input_args[:selected] = selected
      input_args[:include_blank] = true
    end

    controls << f.input(:value, input_args)

    if f.object.cloneable?
      controls << f.input(
        :clone,
        :as => :boolean,
        :input_html => {:class => "input-xxlarge clone-field"},
        :label_html => {:class => "sr-only"},
        :wrapper_html => {:class => "ingest-control clone"},
        :label => "Clone this #{f.object.group}"
      )
    end

    # Super hack, continued: don't put an internal field on the form for sets
    if f.object.group.to_sym != :collection
      controls << f.hidden_field(:internal, :class => "internal-field")
    end

    return controls.reduce { |list, next_control| list << next_control }
  end

  # Centralizes remove link logic for the ingest form
  def link_to_remove_ingest_association(f)
    label = I18n.t("ingest_form.#{f.object.group}.remove", :default => "Remove this #{f.object.group}")
    html = %Q|<span class="sr-only">#{label}</span><i class="icon-trash icon-white"></i>|
    return link_to_remove_association(raw(html), f,
      :class => "btn btn-danger",
      :title => label
    )
  end

  # Centralizes add link logic for the ingest form
  def link_to_add_ingest_association(f, association)
    group = association.to_s.singularize
    label = I18n.t("ingest_form.#{group}.add", :default => "Add #{group}")
    html = %Q|<span class="sr-only">#{label}</span><i class="icon-plus icon-white"></i>|
    return link_to_add_association(raw(html), f, association,
      :class => "btn btn-success",
      :title => label,
      :partial => "ingest/ingest_fields"
    )
  end

  # Returns a default value based largely on simple form's I18n rules, but
  # using the controller name since the ingest form's object name isn't unique
  # amongst all uses (ingest vs. templates).
  def submit_default_value(form)
    key = form.object ? (form.object.persisted? ? :update : :create) : :submit
    defaults = []
    defaults << "%s.%s" % [controller_name.singularize, key]
    defaults << "metadata_ingest_form.%s" % key
    defaults << key
    defaults << "Submit"

    return I18n.t(defaults.shift, scope: [:helpers, :submit], default: defaults)
  end

  # Spits out a form button with classes to use bootstrap styling
  def form_submit(form, opts = {})
    opts[:class] ||= "btn btn-primary"
    opts[:value] ||= submit_default_value(form)
    content_tag(:div, :class => "form-actions") do
      form.submit(opts)
    end
  end

  # Spits out errors partial for showing a bulleted list of form errors
  def form_errors(form)
    render "shared/form_errors", :f => form
  end

  # Uses the same I18n rules as simple_form to return the appropriate error message translation
  # text.  Calls a protected method, so we may have future API issues to deal with, but the only
  # public API option is to hack up how all forms display the error div, which seems like a worse
  # idea than relying on the protected API of a frozen gem.
  def error_notification_for(form)
    return SimpleForm::ErrorNotification.new(form, {}).send(:translate_error_notification)
  end
end
