# Provides utility functions to measure various tree metrics.
module Fizzy::Tree::MetricsHandler
  def self.included(base)
    # @!group Metrics and Measures

    # @!attribute [r] size
    #
    # Total number of nodes in this (sub)tree, including this node.
    #
    # Size of the tree is defined as:
    # *total number nodes in the subtree including this node.*
    #
    # @return [Integer] Total number of nodes in this (sub)tree.
    def size
      inject(0) { |sum, node| sum + 1 if node }
    end

    # @!attribute [r] node_height
    #
    # Height of the (sub)tree from this node.
    #
    # Height of a node is defined as:
    # *length of the longest downward path to a leaf from the node.*
    #
    # - Height from a root node is height of the entire tree.
    # - The height of a leaf node is zero.
    #
    # @return [Integer] Height of the node.
    def node_height
      return 0 if is_leaf?
      1 + @children.collect { |child| child.node_height }.max
    end

    # @!attribute [r] node_depth
    #
    # Depth of this node in its tree.
    #
    # Depth of a node is defined as:
    # *length of the node's path to its root (depth of a root node is zero).*
    #
    # {#level} is an alias for this method.
    #
    # @return [Integer] Depth of this node.
    def node_depth
      return 0 if is_root?
      1 + parent.node_depth
    end

    # @!attribute [r] level
    # Alias for {#node_depth}
    #
    # @see #node_depth
    def level
      node_depth
    end

    # @!attribute [r] breadth
    #
    # Breadth of the tree at this node's level.
    #
    # A single node without siblings has a breadth of 1.
    #
    # Breadth is defined to be:
    # *number of sibling nodes to this node + 1 (this node itself),
    # i.e., the number of children the parent of this node has.*
    #
    # @return [Integer] breadth of the node's level.
    def breadth
      is_root? ? 1 : parent.children.size
    end

    # @!attribute [r] in_degree
    #
    # The incoming edge-count of this node.
    #
    # In-degree is defined as:
    # *number of edges arriving at the node (0 for root, 1 for all other
    # nodes).*
    #
    # - `in_degree == 0` for a root or orphaned node.
    # - `in_degree == 1` for a node which has a parent.
    #
    # @return [Integer] The in-degree of this node.
    def in_degree
      is_root? ? 0 : 1
    end

    # @!attribute [r] out_degree
    #
    # The outgoing edge-count of this node.
    #
    # Out-degree is defined as:
    # *number of edges leaving the node (zero for leafs).*
    #
    # @return [Integer] The out-degree of this node.
    def out_degree
      is_leaf? ? 0 : children.size
    end

    # @!endgroup
  end
end
