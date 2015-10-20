require "fake_go_up/version"
require "fake_go_up/task"
require "pid_lock"

module FakeGoUp
  @@redis = nil

  class << self
    def redis=(conn)
      @@redis = conn
    end

    def run
      pid_name = "FakeGoUp"
      return if PidLock.locked?(pid_name)
      PidLock.lock(pid_name)
      _run
      PidLock.unlock(pid_name)
    end

    def _run
      tasks = FakeGoUp::Task.subclasses.map(&:new)
      while true
        all_finish = true

        tasks.each do |task|
          task.go_up
          all_finish = false unless task.all_finish?
        end

        break if all_finish
        sleep(1)
      end
    end

    def redis
      @@redis
    end
  end
end
