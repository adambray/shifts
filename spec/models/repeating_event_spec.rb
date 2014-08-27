# == Schema Information
#
# Table name: repeating_events
#
#  id                  :integer          not null, primary key
#  start_date          :datetime
#  end_date            :datetime
#  start_time          :datetime
#  end_time            :datetime
#  calendar_id         :integer
#  days_of_week        :string(255)
#  user_id             :integer
#  loc_ids             :string(255)
#  is_set_of_timeslots :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe RepeatingEvent do
  it "should be valid" do
    RepeatingEvent.new.should be_valid
  end
end
