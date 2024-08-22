require 'soft_deletion'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_soft_deletion default_scope: true
end
