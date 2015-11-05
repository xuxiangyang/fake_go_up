require 'test/unit'
require "fake_go_up"
require "pry"
require "redis"
require "hiredis"

class TestFakeGoUp < Test::Unit::TestCase
  setup do
    FakeGoUp.redis = Redis.new(url: "redis://localhost:6379", driver: :hiredis)
    FakeGoUp.redis.del(FakeGoUp.redis.keys) if FakeGoUp.redis.keys.any?
  end
  def test_subclass
    assert_equal [TaskSubclass, TaskSubclass2], FakeGoUp::Task.subclasses
  end

  def test_class_varibale_set
    assert_equal 100, TaskSubclass.instance_variable_get(:@max_fake_count)
    assert_equal 3, TaskSubclass.instance_variable_get(:@interval)
  end

  def test_queue
    item = FakeGoUp::Item.create(1)
    TaskSubclass.queue_up(item, 3)
    assert_equal 3, TaskSubclass.remain(item)
    assert_equal true, TaskSubclass.running?(item)
  end

  def test_hash_key
    assert_equal "fake_go_up:TaskSubclass", TaskSubclass.hash_key
  end

  def test_item_to_field
    item = FakeGoUp::Item.create(1)
    assert_equal "FakeGoUp::Item#1", TaskSubclass.item_to_field(item)
  end

  def test_filed_to_item
    item = FakeGoUp::Item.create(1)
    item.count = 3
    assert_equal item, TaskSubclass.field_to_item("FakeGoUp::Item#1")
  end

  def test_filed_to_item_with_restart
    item = FakeGoUp::Item.create(1)
    item.count = 3

    FakeGoUp::Item.class_variable_set(:@@instance_collector, {}) #fake restart

    new_item = TaskSubclass.field_to_item("FakeGoUp::Item#1")

    assert_equal item.id, new_item.id
    assert_equal item.count, new_item.count
  end

  def test_go_up
    item = FakeGoUp::Item.create(2)
    TaskSubclass.queue_up(item, 3)
    t = TaskSubclass.new
    assert_equal 0, t.cur_step
    assert_equal 0, item.count
    t.go_up
    assert_equal 1, t.cur_step
    assert_equal 3, item.count
  end

  def test_subclass_differnt_interval
    assert TaskSubclass.interval != TaskSubclass2.interval
  end
end

class TaskSubclass < FakeGoUp::Task
  @interval = 3
  @max_fake_count = 100

  def process(item, fake_count)
    item.count = fake_count
  end
end

class TaskSubclass2 < FakeGoUp::Task
  @interval = 2
  @max_fake_count = 100

  def process(item, fake_count)
    item.count = fake_count
  end
end
