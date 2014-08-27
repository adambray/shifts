# == Schema Information
#
# Table name: departments_users
#
#  department_id :integer
#  user_id       :integer
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payrate       :decimal(10, 2)
#

class DepartmentsUser < ActiveRecord::Base

  belongs_to :department
  belongs_to :user
  #this model exists so that the join table can have the bool "active"
  # and we use the "has_many through" relationship
  #thus, a user can be deactivated in any given department without affecting the others.

  #a user also now has a department-specific pay rate!
  #woo-frickin-hoo y'all

end

