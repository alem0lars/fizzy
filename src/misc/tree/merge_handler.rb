#
# Provides utility methods to merge two {Fizzy::Tree::Node} based trees.
#
module Fizzy::Tree::MergeHandler
  # @!group Merging Trees

  #
  # Merge two trees that share the same root node and returns *a new tree*.
  #
  # The new tree contains the contents of the merge between `other_tree` and
  # `self`.
  #
  # Duplicate nodes (coming from `other_tree`) will **NOT** be overwritten in
  # `self`.
  #
  # @param [Fizzy::Tree::Node] other_tree The other tree to merge with.
  #
  # @return [Fizzy::Tree::Node] The resulting tree following the merge.
  #
  # @raise [TypeError] Raised if `other_tree` is not a {Fizzy::Tree::Node}.
  # @raise [ArgumentError] Raised if `other_tree` does not have the same root node as self.
  #
  def merge(other_tree)
    check_merge_prerequisites(other_tree)
    new_tree = merge_trees(self.root.dup, other_tree.root)
    return new_tree
  end

  #
  # Merge in another tree (that shares the same root node) into this tree.
  #
  # Duplicate nodes (coming from `other_tree`) will **NOT** be overwritten in
  # `self`.
  #
  # @param [Fizzy::Tree::Node] other_tree The other tree to merge with.
  #
  # @raise [TypeError] Raised if `other_tree` is not a {Fizzy::Tree::Node}.
  # @raise [ArgumentError] Raised if `other_tree` does not have the same root node as self.
  #
  def merge!(other_tree)
    check_merge_prerequisites(other_tree)
    merge_trees(self.root, other_tree.root)
  end

  #
  # @!visibility protected
  #
  # Utility function to check that the conditions for a tree merge are met.
  #
  # @see #merge
  # @see #merge!
  #
  def check_merge_prerequisites(other_tree)
    unless other_tree.is_a?(Fizzy::Tree::Node)
      raise TypeError,
        'You can only merge in another instance of Fizzy::Tree::Node'
    end

    unless self.root.name == other_tree.root.name
      raise ArgumentError,
        'Unable to merge trees as they do not share the same root'
    end
  end

  protected :check_merge_prerequisites

  #
  # @!visibility protected
  #
  # Utility function to recursivley merge two subtrees.
  #
  # @param [Fizzy::Tree::Node] tree1 The target tree to merge into.
  # @param [Fizzy::Tree::Node] tree2 The donor tree (that will be merged into target).
  #
  # @return [Fizzy::Tree::Node] The merged tree.
  #
  def merge_trees(tree1, tree2)
    names1 = tree1.has_children? ? tree1.children.map { |c| c.name } : []
    names2 = tree2.has_children? ? tree2.children.map { |c| c.name } : []

    names_to_merge = names2 - names1
    names_to_merge.each do |name|
      tree1 << tree2[name].detached_subtree_copy
    end

    tree1.children.each do |child|
      merge_trees(child, tree2[child.name]) unless tree2[child.name].nil?
    end

    return tree1
  end

  protected :merge_trees
end
