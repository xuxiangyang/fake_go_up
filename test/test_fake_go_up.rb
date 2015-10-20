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
    assert_equal [TaskSubclass], FakeGoUp::Task.subclasses
  end

  def test_class_varibale_set
    assert_equal 100, TaskSubclass.class_variable_get(:@@max_fake_count)
    assert_equal 3, TaskSubclass.class_variable_get(:@@interval)
  end

  def test_queue
    item = Item.build(1)
    TaskSubclass.queue_up(item, 3)
    assert_equal 3, TaskSubclass.remain(item)
    assert_equal true, TaskSubclass.running?(item)
  end

  def test_hash_key
    assert_equal "fake_go_up:TaskSubclass", TaskSubclass.hash_key
  end

  def test_item_to_field
    item = Item.build(1)
    assert_equal "Item#1", TaskSubclass.item_to_field(item)
  end

  def test_filed_to_item
    item = Item.build(1)
    assert_equal item, TaskSubclass.field_to_item("Item#1")
  end

  def test_go_up
    item = Item.build(2)
    TaskSubclass.queue_up(item, 3)
    t = TaskSubclass.new
    assert_equal 0, t.cur_step
    assert_equal 0, item.count
    t.go_up
    assert_equal 1, t.cur_step
    assert_equal 3, item.count
  end
end

class Item
  attr_accessor :count
  @@data = {}
  def initialize(id)
    @id = id
    @count = 0
  end

  def id
    @id
  end

  def self.build(id)
    @@data[id] = self.new(id)
    @@data[id]
  end

  def self.find_by_id(id)
    @@data[id.to_i]
  end
end

class TaskSubclass < FakeGoUp::Task
  interval 3
  max_fake_count 100

  def process(item, fake_count)
    item.count = fake_count
  end
end
