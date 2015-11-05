module FakeGoUp
  class Item
    attr_reader :count
    REDIS_KEY = "fake_go_up:items"
    @@instance_collector = {}

    def initialize(id = 1)
      @id = id
      @count = 0
      @@instance_collector[id] = self
    end

    def id
      @id
    end

    def count= (c)
      FakeGoUp.redis.hset(FakeGoUp::Item::REDIS_KEY, id, c)
      @count = c
    end

    def self.find_by_id(id)
      id = id.to_i

      instance = self.instances[id]
      return instance if instance

      count = FakeGoUp.redis.hget(FakeGoUp::Item::REDIS_KEY, id).to_i
      instance = self.new(id)
      instance.count = count
      instance
    end

    def self.create(id)
      id = id.to_i

      FakeGoUp.redis.hset(FakeGoUp::Item::REDIS_KEY, id, 0)
      new(id)
    end

    def self.instances
      @@instance_collector
    end
  end
end
