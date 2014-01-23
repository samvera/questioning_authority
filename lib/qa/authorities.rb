module Qa::Authorities
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Loc
  autoload :Local
  autoload :Subauthority, 'qa/authorities/local/subauthority'
  autoload :Mesh
  autoload :MeshTools
  autoload :Oclcts
  autoload :Tgnlang
  autoload :WebServiceBase
end
