module SchedulesHelper

  def add_schedule_message(schedule)
    "Schedule <strong>#{schedule.name}</strong> successfully added!"
  end

  def update_schedule_message(schedule)
    "Schedule <strong>#{schedule.name}</strong> successfully updated!"
  end

  def delete_schedule_message(schedule)
    "Schedule <strong>#{schedule.name}</strong> successfully deleted!"
  end

  def delete_multiple_schedule_success_message
    'Schedules deleted!'
  end

  def delete_multiple_schedule_fail_message
    'Schedules were not deleted!'
  end

  def delete_multiple_schedule_mix_message(pre, post)
    "Something strange happened... #{pre - post} Schedules weren't deleted."
  end
  
end