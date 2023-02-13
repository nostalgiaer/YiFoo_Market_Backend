class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include ApplicationModelHelper
end
