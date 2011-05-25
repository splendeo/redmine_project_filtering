module RedmineProjectFiltering
  module Patches
    module ProjectPatch

      def self.included(base)
        base.send(:include, RedmineProjectFiltering::WithCustomValues)
        base.class_eval do
          unloadable
        end
      end

    end
  end
end
