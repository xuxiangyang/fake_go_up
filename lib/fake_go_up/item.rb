module FakeGoUp
  class Item
    attr_accessor :count

    @@data = {}

    def initialize(id = 1)
      @id = id
      @count = 0
    end

    def id
      @id
    end

    def self.find_by_id(id)
      @@data[id.to_i]
    end

    def self.create(id)
      instance = new(id)
      @@data[id] = instance
      instance
    end
  end
end