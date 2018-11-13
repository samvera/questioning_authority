module Qa::Authorities
  module LinkedData
    extend ActiveSupport::Autoload
    autoload :GenericAuthority
    autoload :RdfHelper
    autoload :AuthorityService
    autoload :SearchQuery
    autoload :FindTerm
    autoload :Config
  end
end
