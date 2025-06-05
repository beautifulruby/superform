module Superform
  # Superclass for Namespace and Field classes. Not much to it other than it has a `name`
  # and `parent` node attribute. Think of it as a tree.
  class Node
    attr_reader :key, :parent, :factory

    def initialize(key, parent:, factory: nil)
      @key = key
      @parent = parent
      @factory = factory
    end

    protected

    def factory
      @factory || parent&.factory
    end
  end
end
