# Provides utility methods for path extraction.
module Fizzy::Tree::PathHandler
  def self.included(base)
    # @!group Node Path

    # Returns the path of this node from the root as a string, with the node
    # names separated using the specified separator. The path is listed left
    # to right from the root node.
    #
    # @param separator The optional separator to use. The default separator is
    #                  `"=>"`.
    #
    # @return [String] The node path with names separated using the specified
    #                  separator.
    def path_as_string(separator = "=>")
      path_as_array().join(separator)
    end

    # Returns the node-names from this node to the root as an array. The first
    # element is the root node name, and the last element is this node's name.
    #
    # @return [Array] The array containing the node names for the path to this
    # node
    def path_as_array
      get_path_name_array().reverse
    end

    # @!visibility protected
    #
    # Returns the path names in an array. The first element is the name of
    # this node, and the last element is the root node name.
    #
    # @return [Array] An array of the node names for the path from this node
    #                 to its root.
    def get_path_name_array(current_array_path = [])
      path_array = current_array_path + [name]

      if !parent # If detached node or root node.
        return path_array
      else # Else recurse to parent node.
        path_array = parent.get_path_name_array(path_array)
        return path_array
      end
    end

    protected :get_path_name_array

    # @!endgroup
  end
end
