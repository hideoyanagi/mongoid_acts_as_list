module Mongoid::ActsAsList
  module List

    # Internal: Private methods used specifically for root collections (in belongs_to associations)
    #
    # Gets included when calling List.acts_as_list in a root document
    module Root
      extend ActiveSupport::Concern

      module ClassMethods
        private

        def define_position_scope(scope_name)
          #raise List::ScopeMissingError, "#acts_as_list requires a scope option" if scope_name.blank?

          if scope_name.blank?
            define_method(:scope_condition) { {_id: {"$ne" => nil}} }
          else
            scope_name = "#{scope_name}_id".intern if scope_name.to_s !~ /_id$/
						define_method(:scope_condition) { {scope_name => self[scope_name]} }	
 	       	end
        end
      end

      ## InstanceMethods
      private

      def shift_position options = {}
        criteria    = options.fetch(:for, to_criteria)
        by_how_much = options.fetch(:by, 1)

        criteria = criteria.to_criteria if criteria.is_a? self.class

        #db.collection(collection.name).update(criteria.selector, {"$inc" => { position_field => by_how_much }}, {multi: true})
      	self.class.where(criteria.selector).update({"$inc" => { position_field => by_how_much }})
      end

      def to_criteria
        self.class.where(_id: _id)
      end

      def items_in_list
        self.class.where(scope_condition).and(position_field.ne => nil)
      end
    end
  end
end
