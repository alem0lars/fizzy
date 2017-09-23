# Provides utility methods for converting between {Fizzy::Tree::Node} and
# ruby's native `Hash`.
module Fizzy::Tree::HashConverter
  def self.included(base)
    # @!group Hash convertion

    base.extend(ClassMethods)

    # Instantiate and insert child nodes from data in a ruby `Hash`.
    #
    # This method will instantiate a node instance for each top-level key of
    # the input hash, to be inserted as children of the receiver instance.
    #
    # Nested hashes are expected and further child nodes will be created
    # and added accordingly.
    #
    # If a hash key is a single value that value will be used as the
    # name for the node.
    #
    # If a hash key is an `Array`, both node name and content will be
    # populated.
    #
    # A leaf element of the tree should be represented as a hash key
    # with corresponding value `nil` or `{}`.
    #
    # @example
    #   root = Fizzy::Tree::Node.new(:A, "Root content!")
    #   root.add_from_hash({:B => {:D => {}}, [:C, "C content!"] => {}})
    #
    # @param [Hash] children The hash of child subtrees.
    #
    # @return [Array] Array of child nodes added.
    #
    # @raise [ArgumentError] If a non-`Hash` is passed.
    #
    # @see ClassMethods#from_hash
    def add_from_hash(children)
      must "children", children, be: Hash

      child_nodes = []
      children.each do |child, grandchildren|
        child_node = self.class.from_hash({ child => grandchildren })
        child_nodes << child_node
        self << child_node
      end

      child_nodes
    end

    # Convert a node and its subtree into a ruby `Hash`.
    #
    # @example
    #   root  = Fizzy::Tree::Node.new(:root, "root content")
    #   root << Fizzy::Tree::Node.new(:child1, "child1 content")
    #   root << Fizzy::Tree::Node.new(:child2, "child2 content")
    #   root.to_h # => { [:root, "root content"] =>
    #                      { [:child1, "child1 content"] => {},
    #                        [:child2, "child2 content"] => {} } }
    #
    # @return [Hash] `Hash` representation of the tree.
    def to_h
      key = has_content? ? [name, content] : name

      children_hash = {}
      children do |child|
        children_hash.merge! child.to_h
      end

      { key => children_hash }
    end
  end

  # Methods in {Fizzy::Tree::HashConverter::ClassMethods} will be added as
  # class methods on any class mixing in the {Fizzy::Tree::HashConverter}
  # module.
  module ClassMethods
    # Factory method builds a {Fizzy::Tree::Node} from a `Hash`.
    #
    # This method will interpret each key of your `Hash` as a
    # {Fizzy::Tree::Node}.
    #
    # Nested hashes are expected and child nodes will be added accordingly.
    #
    # If a hash key is a single value that value will be used as the name for
    # the node.
    #
    # If a hash key is an Array, both node name and content will be
    # populated.
    #
    # A leaf element of the tree should be represented as a hash key with
    # corresponding value `nil` or `{}`.
    #
    # @example
    #
    #   TreeNode.from_hash({:A => {:B => {}, :C => {:D => {}, :E => {}}}})
    #   # ^- would be parsed into the following tree structure:
    #   #
    #   #    A
    #   #   / \
    #   #  B   C
    #   #     / \
    #   #    D   E
    #
    #   # The same tree would result from this `nil`-terminated `Hash`.
    #   {:A => {:B => nil, :C => {:D => nil, :E => nil}}}
    #
    #   # A tree with equivalent structure but with content present for
    #   # nodes A and D could be built from a hash like this:
    #   {[:A, "A content"] => {:B => {},
    #                          :C => { [:D, "D content"] => {},
    #                                   :E => {}  }}}
    #
    # @param [Hash] hash Hash to build tree from.
    #
    # @return [Fizzy::Tree::Node] The node representing the root of your tree.
    #
    # @raise [ArgumentError] This exception is raised if a non-`Hash` is
    #                        passed.
    # @raise [ArgumentError] This exception is raised if the hash has multiple
    #                        top-level elements.
    # @raise [ArgumentError] This exception is raised if `hash` contains
    #                        values that are not `Hash`es or `nil`s.
    def from_hash(hash)
      must "hash", hash, be: Hash
      must "hash size", hash.size, eq: 1

      root, children = hash.first

      must "hash children", children, be: [Hash, NilClass]

      node = self.new(*root)
      node.add_from_hash(children) unless children.nil?
      node
    end
  end

  # @!endgroup
end
