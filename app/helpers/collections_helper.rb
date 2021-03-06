module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior
  include Blacklight::BlacklightHelperBehavior

  def controlled_view(pid)
    # Find documents which have info about this pid.
    return controlled_view_label(pid).find{|x| !x.blank?}.to_s
  end

  def controlled_view_label(label)
    return controlled_view_label(label[:document][label[:field]]) if label.kind_of?(Hash)
    Array.wrap(label).map do |x|
      new_label = x.split("$")
      if new_label.first == new_label.last
        ""
      else
        new_label.first.strip
      end
    end
  end

  def render_set(set)
    renderer = SetRenderer.new(set, lookup_context, params)
    render :template => renderer.partial_name
  end

  def add_facet_params_and_redirect(field, item)
    if field == ActiveFedora::SolrService.solr_name("desc_metadata__set_label", :facetable) && params[:search_field].blank? && params[:f].blank?
      {
          :controller => "sets",
          :action => "index",
          :set => GenericCollection.id_param(item.split("$").last)
      }
    else
      super
    end
  end

  # Maintain context when linking to documents
  def link_to_document(doc, opts={:label => nil, :counter => nil}, &block)
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    solr_document = doc

    # If set is nil, send to catalog controller
    if params[:controller] == "sets" && params[:set]
      doc = {:controller => "sets", :action => "show", :set => params[:set], :id => doc["id"]}
    else
      doc = {:controller => "catalog", :action => "show", :id => doc["id"]}
    end
    if block_given?
      link_to doc.merge(:anchor => document_anchor(solr_document)), { :'data-counter' => opts[:counter] }.merge(opts.reject { |k,v| [:label, :counter].include? k  }), &block
    else
      link_to label, doc.merge(:anchor => document_anchor(solr_document)), { :'data-counter' => opts[:counter] }.merge(opts.reject { |k,v| [:label, :counter].include? k  })
    end
  end

  def document_anchor(solr_document)
    "page/1/mode/1up/search/#{params[:q].to_s.gsub('"',"")}" if solr_document["active_fedora_model_ssi"] == "Document"
  end

  def path_to_document(doc)
    url_args = {:action => "show", :id => doc["id"]}
    if params[:controller] == "sets"
      url_args[:controller] = "sets"
      url_args[:set] = params[:set]
    end

    url_for url_args
  end

  def link_to_previous_document(doc)
    label = raw(t('views.pagination.previous'))
    unless doc.present?
      return content_tag :span, label, :class => 'previous'
    end

    counter = session[:search][:counter].to_i - 1
    link_to label, path_to_document(doc), :class => "previous", :rel => 'prev', :'data-counter' => counter
  end

  def link_to_next_document(doc)
    label = raw(t('views.pagination.next'))
    unless doc.present?
      return content_tag :span, label, :class => 'next'
    end

    counter = session[:search][:counter].to_i + 1
    link_to label, path_to_document(doc), :class => "next", :rel => 'next', :'data-counter' => counter
  end

  ##
  # This isn't particularly pretty - this was added as an alternative to overriding more Blacklight views.
  # TODO: Improve me.
  def catalog_index_path(*args)
    if params[:controller] == "sets"
      if args.last.kind_of?(Hash)
        args.last.merge!({:set => params[:set]})
      else
        args << {:set => params[:set]}
      end
      return sets_path(*(args))
    end
    super
  end

end
