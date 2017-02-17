require 'spec_helper'

describe "QA Routes", type: :routing do
  routes { Qa::Engine.routes }

  context 'searching for terms' do
    it 'routes to searching for an authority' do
      expect(get: '/search/linked_data/test_authority').to route_to(controller: 'qa/linked_data_terms',
                                                                    action: 'search',
                                                                    vocab: 'test_authority')
    end
    it 'routes to searching for an authority and a subauthority' do
      expect(get: '/search/linked_data/test_authority/test_subauthority').to route_to(controller: 'qa/linked_data_terms',
                                                                                      action: 'search',
                                                                                      vocab: 'test_authority',
                                                                                      subauthority: 'test_subauthority')
    end
  end

  context 'displaying a single term' do
    it 'routes to an authority' do
      expect(get: '/show/linked_data/test_authority/term_id').to route_to(controller: 'qa/linked_data_terms',
                                                                          action: 'show',
                                                                          vocab: 'test_authority',
                                                                          id: 'term_id')
    end
    it 'routes to an authority with a subauthority' do
      expect(get: '/show/linked_data/test_authority/test_subauthority/term_id').to route_to(controller: 'qa/linked_data_terms',
                                                                                            action: 'show',
                                                                                            vocab: 'test_authority',
                                                                                            subauthority: 'test_subauthority',
                                                                                            id: 'term_id')
    end
  end
end
