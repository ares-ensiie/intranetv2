module FilesHelper
  def get_icon(content)
    if content.is_a?(String)
      return "fa-folder-open"
    else
      return "fa-file-o"
    end
  end
end
