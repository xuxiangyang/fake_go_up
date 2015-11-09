# -*- coding: utf-8 -*-
module FakeGoUp
  class Task
    attr_reader :cur_step

    MAX_INTERVAL = 24 * 60 * 60
    @max_fake_count = 20
    @interval = 1
    @@subclass = []

    def initialize
      @cur_step = 0
    end

    def process(item, fake_count)
      raise "you need overwrite this func"
    end

    def all_finish?
      FakeGoUp.redis.hkeys(self.class.hash_key).length == 0
    end

    def go_up
      return unless self.cur_step % self.class.interval == 0
      FakeGoUp.redis.hkeys(self.class.hash_key).each do |field|
        go_up_one_field(field)
      end
    ensure
      self.next_step
    end

    def go_up_one_field(field)
      remain_count = FakeGoUp.redis.hget(self.class.hash_key, field).to_i
      fake_count = rand(self.class.max_fake_count)
      if remain_count < fake_count
        fake_count = remain_count
        FakeGoUp.redis.hdel(self.class.hash_key, field)
      else
        remain_count = remain_count - fake_count
        FakeGoUp.redis.hset(self.class.hash_key, field, remain_count)
      end

      return unless fake_count > 0
      item = self.class.field_to_item(field)
      if item.nil?
        FakeGoUp.redis.hdel(self.class.hash_key, field)
      else
        process(item, fake_count)
      end
    end

    def next_step
      @cur_step = (@cur_step + 1) % MAX_INTERVAL
    end

    class << self
      def queue_up(item, count)
        field = item_to_field(item)
        FakeGoUp.redis.hset(self.hash_key, field, count)
      end

      def remain(item)
        field = item_to_field(item)
        FakeGoUp.redis.hget(self.hash_key, field).to_i
      end

      def interval
        @interval
      end

      def max_fake_count
        @max_fake_count
      end

      def running?(item)
        field = item_to_field(item)
        FakeGoUp.redis.hkeys(self.hash_key).include?(field)
      end

      def subclasses
        @@subclass
      end

      def inherited(subclass)
        @@subclass << subclass
        super
      end

      def item_to_field(item)
        "#{item.class}##{item.id}"
      end

      def field_to_item(field)
        item_class_name, item_id = field.split("#")
        eval(item_class_name).find_by_id(item_id)
      end

      def hash_key
        "fake_go_up:#{self.name}"
      end
    end
  end
end
