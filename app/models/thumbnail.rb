class Thumbnail < ApplicationRecord

  has_attachment :storage => :file_system,
    :content_type => :image, :max_size => 5.megabytes, processor: 'Rmagick'

  validates_as_attachment

  sanitize_filename

  postgresql_attachment_fu

end
