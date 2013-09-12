class Image < GenericAsset
  include Hydra::Derivatives
  has_file_datastream :name => 'thumbnail'
  has_file_datastream :name => 'pyramidal'

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
            :datastream => 'pyramidal'
        }
    }, :processor => :pyramidal_processor
  end

end
