require 'active_support'
require 'active_support/core_ext'

module Qa::Authorities
  extend ActiveSupport::Autoload

  autoload :AuthorityWithSubAuthority
  autoload :Base
  autoload :Getty
  autoload :Geonames
  autoload :Loc
  autoload :LocSubauthority
  autoload :Local
  autoload :LocalSubauthority
  autoload :Mesh
  autoload :MeshTools
  autoload :Oclcts
  autoload :Tgnlang
  autoload :WebServiceBase
  autoload :AssignFast
  autoload :AssignFastSubauthority
  autoload :Crossref
  autoload :LinkedData
  autoload :Discogs
  autoload :DiscogsSubauthority
end
