module IngestHelper
  # Renders the ingest form for the given form object
  def ingest_form_for(ingest_form)
    url = ingest_path(ingest_form)
    html_options = {:multipart => true, :class => "form-inline"}

    simple_form_for(ingest_form, {:url => url, :html => html_options}) do |f|
      yield(f)
    end
  end

  # Spits out all necessary fields for an ingest form "field group", adding
  # classes for styling and controlled vocab magic
  def type_value_fields(f)
    controls = []

    controls << f.input(
      :type,
      :collection => INGEST_MAP[f.object.group.to_sym].keys,
      :input_html => {:class => "input-medium type-selector"},
      :label_html => {:class => "sr-only"},
      :wrapper_html => {:class => "ingest-control type"}
    )

    controls << f.input(
      :value,
      :input_html => {:class => "input-xxlarge value-field"},
      :label_html => {:class => "sr-only"},
      :wrapper_html => {:class => "ingest-control value"}
    )

    controls << f.hidden_field(:internal, :class => "internal-field")

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

  # Spits out a form button with classes to use bootstrap styling
  def form_submit(form, opts = {})
    opts[:class] ||= "btn btn-primary"
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
