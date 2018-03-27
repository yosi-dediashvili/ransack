module Ransack
  module Nodes
    module Bindable

      attr_accessor :parent, :attr_name

      def attr
        @attr ||= get_arel_attribute
      end
      alias :arel_attribute :attr

      def ransacker
        klass._ransackers[attr_name]
      end

      def klass
        @klass ||= context.klassify(parent)
      end

      def bound?
        # Originally, parent was checked with `present?`, but that might actually initiate a 
        # DB query for the size of the collection. So any empty collection will evaluate to 
        # false. So instead we'll use the simple `nil?` check.
        attr_name.present? && parent.nil?
      end

      def reset_binding!
        @parent = @attr_name = @attr = @klass = nil
      end

      private

      def get_arel_attribute
        if ransacker
          ransacker.attr_from(self)
        else
          get_attribute
        end
      end

      def get_attribute
        if is_alias_attribute?
          context.table_for(parent)[parent.base_klass.attribute_aliases[attr_name]]
        else
          context.table_for(parent)[attr_name]
        end
      end

      def is_alias_attribute?
        Ransack::SUPPORTS_ATTRIBUTE_ALIAS &&
        parent.base_klass.attribute_aliases.key?(attr_name)
      end
    end
  end
end
