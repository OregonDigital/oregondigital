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
    if params[:controller] == "sets"
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

  def link_to_previous_document(previous_document)
    if params[:controller] == "sets" && previous_document.present?
      previous_document = {:controller => "sets", :action => "show", :set => params[:set], :id => previous_document["id"]}
    end
    super
  end

  def link_to_next_document(next_document)
    if params[:controller] == "sets" && next_document.present?
      next_document = {:controller => "sets", :action => "show", :set => params[:set], :id => next_document["id"]}
    end
    super
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
