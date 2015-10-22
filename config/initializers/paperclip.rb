Paperclip::Attachment.default_options[:s3_credentials] = {
  :bucket => APP_CONFIG['aws']['bucket-profiles'],
  :access_key_id => APP_CONFIG['aws']['access_key_id'],
  :secret_access_key => APP_CONFIG['aws']['secret_access_key']
}
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'

# For development
Paperclip::Attachment.default_options[:fog_credentials] = { provider: "Local", local_root: "#{Rails.root}/public"}
Paperclip::Attachment.default_options[:fog_directory] = ""
Paperclip::Attachment.default_options[:fog_host] = "http://localhost:3000"
