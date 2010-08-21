class Option < ActiveRecord::Base
  validates_presence_of :option_name
  validates_uniqueness_of :option_name
end