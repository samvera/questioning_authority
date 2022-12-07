module Qa
  # @api public
  # @since v5.11.0
  #
  # The intention of this wrapper is to provide a common interface that both linked and non-linked
  # data can use.  There are implementation differences between the two, but with this wrapper, the
  # goal is to draw attention to those differences and insulate the end user from those issues.
  #
  # One benefit in introducing this class is that when interacting with a questioning authority
  # implementation you don't need to consider "Hey when I instantiate an authority, is this linked
  # data or not?"  And what specifically are the parameter differences.  You will need to perhaps
  # include some additional values in the context if you don't call this from a controller.
  class AuthorityWrapper
    # @param authority [#find, #search]
    # @param subauthority [#to_s]
    # @param context [#params, #search_header, #fetch_header]
    def initialize(authority:, subauthority:, context:)
      @authority = authority
      @subauthority = subauthority
      @context = context
      configure!
    end
    attr_reader :authority, :context, :subauthority

    def search(value)
      if linked_data?
        # should respond to search_header
        authority.search(value, request_header: context.search_header)
      elsif authority.method(:search).arity == 2
        # This context should respond to params; see lib/qa/authorities/discogs/generic_authority.rb
        authority.search(value, context)
      else
        authority.search(value)
      end
    end

    # context has params
    def find(value)
      if linked_data?
        # should respond to fetch_header
        authority.find(value, request_header: context.fetch_header)
      elsif authority.method(:find).arity == 2
        authority.find(value, context)
      else
        authority.find(value)
      end
    end
    alias fetch find

    def method_missing(method_name, *arguments, &block)
      authority.send(method_name, *arguments, &block)
    end

    def respond_to_missing?(method_name, include_private = false)
      authority.respond_to?(method_name, include_private)
    end

    def configure!
      @context.subauthority = @subauthority if @context.respond_to?(:subauthority)
    end
  end
end
