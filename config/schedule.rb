# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
#
# Learn more: http://github.com/javan/whenever

set :output, '/var/log/cron_jobs.log'
set :job_template, "source #{File.expand_path File.dirname(__dir__)}/export_env.sh; bash -c ':job'"
env :PATH, ENV['PATH']

every 1.day, at: '1:00 am' do
  command 'echo Cronjob every day at 1:00 am. Executed: `date`', output: '/var/log/cron_check.log'
  rake 'mammooc:update_course_data'
  rake 'mammooc:update_user_data'
  rake 'mammooc:send_reminders'
  rake 'mammooc:send_newsletters'
end

every 1.hour do
  command 'echo Cronjob every hour. Executed: `date`', output: '/var/log/cron_check.log'
  rake 'mammooc:synchronize_dates_for_all_users'
end
