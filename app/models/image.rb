class Image < GenericAsset
  has_file_datastream :name => 'thumbnail'
  has_file_datastream :name => 'pyramidal', :control_group => "E"

  makes_derivatives :create_thumbnail, :create_pyramidal


  # Derivative Creation Methods

  def create_thumbnail
    transform_datastream :content, {
        :thumb => {
                  :size => '120x120>',
                  :datastream => 'thumbnail'
        } }
  end

  def create_pyramidal
    transform_datastream :content, {
        :pyramidal => {
            :datastream => 'pyramidal',
            :file_path => pyramidal_tiff_location
        }
    }, :processor => :pyramidal_processor
  end

  def pyramidal_tiff_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG.pyramidal_tiff_path || Rails.root.join("media", "pyramidal-tiffs")
    return fd.path
  end

end
