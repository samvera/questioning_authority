# Encapsulate information about assignFAST subauthorities
module Qa::Authorities::AssignFastSubauthority
  # Hash of subauthority names used in qa routes => 'index' used by API
  SUBAUTHORITIES = {
    'all'        => 'suggestall',
    'personal'   => 'suggest00',
    'corporate'  => 'suggest10',
    'event'      => 'suggest11',
    'uniform'    => 'suggest30',
    'topical'    => 'suggest50',
    'geographic' => 'suggest51',
    'form_genre' => 'suggest55'
  }.freeze

  # Get a list of subauthorities by name
  #
  # @return [Array<String>]
  def subauthorities
    SUBAUTHORITIES.keys
  end

  # Get an API index name from an English name
  #
  # @param [String] English name
  # @return [String] index name
  def index_for_authority(authority)
    SUBAUTHORITIES[authority]
  end
end
