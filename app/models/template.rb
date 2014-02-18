# Special subclass of assets specifically built to hold pre-filled form data
class Template < GenericAsset
  def name
    return title
  end

  private

  # Sets @needs_derivatives to false to ensure templates never accidentally do
  # anything we wouldn't want
  def check_derivatives
    @needs_derivatives = false
    return true
  end
end
