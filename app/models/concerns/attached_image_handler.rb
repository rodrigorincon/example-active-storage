module AttachedImageHandler
  extend ActiveSupport::Concern

  included do
    before_create :set_filename
  end

  def file
    object_name = self.attachment_reflections.keys.first
    self.send(object_name)
  end

  def image_url
    file.url.split("?").first
  end

  def set_filename
    if file.attached?
      extension = file.filename.extension
      prefix_bucket = Rails.application.config.active_storage.prefix
      file.blob.update(key: "#{prefix_bucket}/#{self.email}.#{extension}_#{file.key}.#{extension}")
    end
  end
end