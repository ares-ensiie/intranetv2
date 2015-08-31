require "s3"
class FilesController < ApplicationController
  def index
    service = S3::Service.new(:access_key_id => APP_CONFIG["aws"]["access_key_id"],
                              :secret_access_key => APP_CONFIG["aws"]["secret_access_key"])


    path_name = params[:path] || ""

    @path = [{
               name: "Home",
               path:"/"
    }]

    cur_path = ""
    path_name.split("/").each do | directory |
      cur_path += "/"+directory
      @path.append({
                     name: directory,
                     path: cur_path
      })
    end

    bucket = service.buckets.find(APP_CONFIG["aws"]["bucket"])
    @files = Hash.new
    bucket.objects.each do | file |
      if file.key.start_with?(path_name)
        if path_name.length != 0
          file_path = file.key[path_name.length + 1..-1]
        else
          file_path = file.key
        end
        adjacent_folder = File.dirname(file_path).split("/")[0]
        if adjacent_folder == "."
          @files[File.basename(file.key)] = file
        else
          @files[adjacent_folder] = path_name+"/"+adjacent_folder
        end
      end
    end
  end
end
