class OaiController < ApplicationController
  def index
    # Remove controller and action from the options.  Rails adds them automatically.
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    provider = OregonDigital::OAI::Provider.new
    response =  provider.process_request(options)
    render :text => response, :content_type => 'text/xml'
  end
end