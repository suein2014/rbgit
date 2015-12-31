require 'dalli'
class Article < ActiveRecord::Base
  belongs_to :category
  validates :title, presence: true, length: {maximum: 50}
  validates :content, presence: true
  

end