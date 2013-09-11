class Image < GenericAsset
  include Hydra::Derivatives
  has_file_datastream :name => 'thumbnail'
  has_file_datastream :name => 'pyramidal'

  makes_derivatives do |obj|
    obj.transform_datastream :content, {
        :thumb => {
                  :size => '120x120>',
                  :datastream => 'thumbnail'
        } }

  end

end