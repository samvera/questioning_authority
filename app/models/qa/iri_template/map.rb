module Qa
  module IriTemplate
    class Map
      TYPE = "IriTemplateMapping".freeze
      attr_reader :variable # [String] name of the variable in the template (e.g. {?query} has the name 'query')
      attr_reader :property # [String] always "hydra:freetextQuery" # TODO what other values are supported and what do they mean
      attr_reader :required # [True | False] true, if the value of the variable must be provided; otherwise, false
      attr_reader :default  # [String] value to use if a value is not provided

      def initialize(map)
        @variable = map.fetch(:variable)
        @property = map.fetch(:property, "hydra:freetextQuery")
        @required = map.fetch(:required, true)
        @default = map.fetch(:default, "")
      end
    end
  end
end
