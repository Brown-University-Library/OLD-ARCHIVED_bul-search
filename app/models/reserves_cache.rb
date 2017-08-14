class ReservesCache < ActiveRecord::Base
  default_scope { order(number: :asc, section: :asc) }
end
