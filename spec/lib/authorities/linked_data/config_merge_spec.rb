require 'spec_helper'
require 'qa/authorities/linked_data/config/config_merge'.freeze

describe Qa::Authorities::LinkedData::ConfigMerge do
  before do
    @min_config = Qa::Authorities::LinkedData::Config.new(:LOD_MIN_CONFIG)
    @full_config = Qa::Authorities::LinkedData::Config.new(:LOD_FULL_CONFIG)
  end

  after do
    LINKED_DATA_AUTHORITIES_CONFIG[:LOD_MIN_CONFIG] =
      {
        term: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/term/{?term_id}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [{ :@type => 'IriTemplateMapping', variable: 'term_id', property: 'hydra:freetextQuery', required: true }]
          },
          qa_replacement_patterns: { term_id: 'term_id' },
          term_id: 'URI',
          results: { id_predicate: 'http://id.loc.gov/vocabulary/identifiers/lccn', label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel' }
        },
        search: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/search?query={?query}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [{ :@type => 'IriTemplateMapping', variable: 'query', property: 'hydra:freetextQuery', required: true }]
          },
          qa_replacement_patterns: { query: 'query' },
          results: { id_predicate: 'http://purl.org/dc/terms/identifier', label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel' }
        }
      }

    LINKED_DATA_AUTHORITIES_CONFIG[:LOD_FULL_CONFIG] =
      {
        term: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/term/{?subauth}/{?term_id}?param1={?param1}&param2={?param2}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              { :@type => 'IriTemplateMapping', variable: 'term_id', property: 'hydra:freetextQuery', required: true },
              { :@type => 'IriTemplateMapping', variable: 'subauth', property: 'hydra:freetextQuery', required: false, default: 'term_sub2_name' },
              { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'alpha' },
              { :@type => 'IriTemplateMapping', variable: 'param2', property: 'hydra:freetextQuery', required: false, default: 'beta' }
            ]
          },
          qa_replacement_patterns: { term_id: 'term_id', subauth: 'subauth' },
          term_id: 'ID',
          language: ['en'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
            narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
            sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
          },
          subauthorities: { term_sub1_key: 'term_sub1_name', term_sub2_key: 'term_sub2_name', term_sub3_key: 'term_sub3_name' }
        },
        search: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              { :@type => 'IriTemplateMapping', variable: 'query', property: 'hydra:freetextQuery', required: true },
              { :@type => 'IriTemplateMapping', variable: 'subauth', property: 'hydra:freetextQuery', required: false, default: 'search_sub1_name' },
              { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'delta' },
              { :@type => 'IriTemplateMapping', variable: 'param2', property: 'hydra:freetextQuery', required: false, default: 'echo' }
            ]
          },
          qa_replacement_patterns: { query: 'query', subauth: 'subauth' },
          language: ['en', 'fr', 'de'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
          },
          subauthorities: { search_sub1_key: 'search_sub1_name', search_sub2_key: 'search_sub2_name', search_sub3_key: 'search_sub3_name' }
        }
      }
  end

  describe '#merge_term' do
    context 'when setting term_id' do
      it 'changes term_id setting from URI to ID' do
        Qa::Authorities::LinkedData::Config.merge_term(@min_config.term_config, term_id: 'ID')
        expect(@min_config.term_id_expects_uri?).to eq false
        expect(@min_config.term_id_expects_id?).to eq true
      end

      it 'changes term_id setting from ID to URI' do
        Qa::Authorities::LinkedData::Config.merge_term(@full_config.term_config, term_id: 'URI')
        expect(@full_config.term_id_expects_uri?).to eq true
        expect(@full_config.term_id_expects_id?).to eq false
      end
    end

    context 'when setting language' do
      it 'adds the language setting when it does not exist' do
        Qa::Authorities::LinkedData::Config.merge_term(@min_config.term_config, language: ['en', 'fr'])
        expect(@min_config.term_language).to eq [:en, :fr]
      end

      it 'replaces the language setting' do
        Qa::Authorities::LinkedData::Config.merge_term(@full_config.term_config, language: ['fr', 'de'])
        expect(@full_config.term_language).to eq [:fr, :de]
      end
    end
  end

  describe '#merge_search' do
    context 'when setting language' do
      it 'adds the language setting when it does not exist' do
        Qa::Authorities::LinkedData::Config.merge_search(@min_config.search_config, language: ['en', 'fr'])
        expect(@min_config.search_language).to eq [:en, :fr]
      end

      it 'replaces the language setting' do
        Qa::Authorities::LinkedData::Config.merge_search(@full_config.search_config, language: ['fr', 'de'])
        expect(@full_config.search_language).to eq [:fr, :de]
      end
    end
  end

  describe '#merge_url' do
    context 'when setting tempate' do
      it 'replaces template for url' do
        Qa::Authorities::LinkedData::Config.merge_url(@min_config.search_url, template: 'http://www.example.com/ALTERNATE_URL/{?query}')
        expect(@min_config.search_url_template).to eq 'http://www.example.com/ALTERNATE_URL/{?query}'
      end
    end

    context 'when setting mapped variables' do
      let(:added_map_var) do
        {
          :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
          :@type => 'IriTemplate',
          template: 'http://localhost/test_default/term/{?term_id}',
          variableRepresentation: 'BasicRepresentation',
          mapping: [
            { :@type => 'IriTemplateMapping', variable: 'term_id', property: 'hydra:freetextQuery', required: true },
            { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'foxtrot' }
          ]
        }
      end
      it 'add mapping for a variable' do
        Qa::Authorities::LinkedData::Config.merge_url(@min_config.term_url, mapping: [{ :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'foxtrot' }])
        expect(@min_config.term_url).to eq added_map_var
      end

      let(:replaced_default) do
        {
          :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
          :@type => 'IriTemplate',
          template: 'http://localhost/test_default/term/{?subauth}/{?term_id}?param1={?param1}&param2={?param2}',
          variableRepresentation: 'BasicRepresentation',
          mapping: [
            { :@type => 'IriTemplateMapping', variable: 'term_id', property: 'hydra:freetextQuery', required: true },
            { :@type => 'IriTemplateMapping', variable: 'subauth', property: 'hydra:freetextQuery', required: false, default: 'NEW_SUBAUTH' },
            { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'alpha' },
            { :@type => 'IriTemplateMapping', variable: 'param2', property: 'hydra:freetextQuery', required: false, default: 'GOLF' }
          ]
        }
      end
      it 'replaces default' do
        Qa::Authorities::LinkedData::Config.merge_url(@full_config.term_url, mapping: [{ variable: 'subauth', default: 'NEW_SUBAUTH' }, { variable: 'param2', default: 'GOLF' }])
        expect(@full_config.term_url).to eq replaced_default
      end
    end
  end

  describe '#merge_reppatterns' do
    context 'for terms' do
      let(:extended_patterns) do
        {
          term_id: 'term_id',
          subauth: 'ADDED_SUBAUTH'
        }
      end
      it 'adds predicates' do
        Qa::Authorities::LinkedData::Config.merge_reppatterns(@min_config.term_qa_replacement_patterns, subauth: 'ADDED_SUBAUTH')
        expect(@min_config.term_qa_replacement_patterns).to eq extended_patterns
      end

      let(:replaced_patterns) do
        {
          term_id: 'MOD_term_id',
          subauth: 'subauth'
        }
      end
      it 'replaces predicates' do
        Qa::Authorities::LinkedData::Config.merge_reppatterns(@full_config.term_qa_replacement_patterns, term_id: 'MOD_term_id')
        expect(@full_config.term_qa_replacement_patterns).to eq replaced_patterns
      end
    end

    context 'for search' do
      let(:extended_patterns) do
        {
          query: 'query',
          subauth: 'ADDED_SUBAUTH'
        }
      end
      it 'adds predicates' do
        Qa::Authorities::LinkedData::Config.merge_reppatterns(@min_config.search_qa_replacement_patterns, subauth: 'ADDED_SUBAUTH')
        expect(@min_config.search_qa_replacement_patterns).to eq extended_patterns
      end

      let(:replaced_patterns) do
        {
          query: 'MOD_query',
          subauth: 'subauth'
        }
      end
      it 'replaces predicates' do
        Qa::Authorities::LinkedData::Config.merge_reppatterns(@full_config.search_qa_replacement_patterns, query: 'MOD_query')
        expect(@full_config.search_qa_replacement_patterns).to eq replaced_patterns
      end
    end
  end

  describe '#merge_results' do
    context 'for terms' do
      let(:extended_results) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
          narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower'
        }
      end
      it 'adds predicates' do
        Qa::Authorities::LinkedData::Config.merge_results(@min_config.term_results,
                                                          id_predicate: 'http://purl.org/dc/terms/identifier',
                                                          broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
                                                          narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower')
        expect(@min_config.term_results).to eq extended_results
      end

      let(:replaced_results) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
          broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
          narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
          sameas_predicate: 'http://schema.org/sameAs'
        }
      end
      it 'replaces predicates' do
        Qa::Authorities::LinkedData::Config.merge_results(@full_config.term_results, sameas_predicate: 'http://schema.org/sameAs')
        expect(@full_config.term_results).to eq replaced_results
      end
    end

    context 'for search' do
      let(:extended_results) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel'
        }
      end
      it 'adds predicates' do
        Qa::Authorities::LinkedData::Config.merge_results(@min_config.search_results, altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel')
        expect(@min_config.search_results).to eq extended_results
      end

      let(:replaced_results) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
          sort_predicate: 'http://purl.org/dc/terms/identifier'
        }
      end
      it 'replaces predicates' do
        Qa::Authorities::LinkedData::Config.merge_results(@full_config.search_results, sort_predicate: 'http://purl.org/dc/terms/identifier')
        expect(@full_config.search_results).to eq replaced_results
      end
    end
  end

  describe '#merge_subauths' do
    context 'when subauths NOT defined' do
      it 'adds subauths' do
        expected_hash = {
          new_subauth1_key: 'subauth_1',
          new_subauth2_key: 'subauth_2'
        }
        Qa::Authorities::LinkedData::Config.merge_subauths(@min_config.term_subauthorities, new_subauth1_key: 'subauth_1', new_subauth2_key: 'subauth_2')
        expect(@min_config.term_subauthorities).to eq expected_hash
      end
    end

    context 'when subauths are defined' do
      let(:subauths_after_add) do
        {
          term_sub1_key: 'term_sub1_name',
          term_sub2_key: 'term_sub2_name',
          term_sub3_key: 'term_sub3_name',
          new_subauth1_key: 'subauth_1',
          new_subauth2_key: 'subauth_2'
        }
      end
      it 'adds subauths' do
        Qa::Authorities::LinkedData::Config.merge_subauths(@full_config.term_subauthorities, new_subauth1_key: 'subauth_1', new_subauth2_key: 'subauth_2')
        expect(@full_config.term_subauthorities).to eq subauths_after_add
      end

      let(:subauths_after_replace) do
        {
          term_sub1_key: 'NEW_SUBAUTH_NAME',
          term_sub2_key: 'term_sub2_name',
          term_sub3_key: 'term_sub3_name'
        }
      end
      it 'replaces subauths' do
        Qa::Authorities::LinkedData::Config.merge_subauths(@full_config.term_subauthorities, term_sub1_key: 'NEW_SUBAUTH_NAME')
        expect(@full_config.term_subauthorities).to eq subauths_after_replace
      end

      let(:subauths_after_add_and_replace) do
        {
          term_sub1_key: 'NEW_SUBAUTH_NAME',
          term_sub2_key: 'term_sub2_name',
          term_sub3_key: 'term_sub3_name',
          new_subauth1_key: 'subauth_1'
        }
      end
      it 'add and replaced subauths' do
        Qa::Authorities::LinkedData::Config.merge_subauths(@full_config.term_subauthorities, term_sub1_key: 'NEW_SUBAUTH_NAME', new_subauth1_key: 'subauth_1')
        expect(@full_config.term_subauthorities).to eq subauths_after_add_and_replace
      end
    end
  end

  # describe '#auth_config' do
  #   let(:full_auth_config) do
  #     {
  #       term: {
  #         url: {
  #           :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
  #           :@type => 'IriTemplate',
  #           template: 'http://localhost/test_default/term/{?subauth}/{?term_id}?param1={?param1}&param2={?param2}',
  #           variableRepresentation: 'BasicRepresentation',
  #           mapping: [
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'term_id',
  #               property: 'hydra:freetextQuery',
  #               required: true
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'subauth',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'term_sub2_name'
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'param1',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'alpha'
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'param2',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'beta'
  #             }
  #           ]
  #         },
  #         qa_replacement_patterns: {
  #           term_id: 'term_id',
  #           subauth: 'subauth'
  #         },
  #         term_id: 'ID',
  #         language: ['en'],
  #         results: {
  #           id_predicate: 'http://purl.org/dc/terms/identifier',
  #           label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
  #           altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
  #           broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
  #           narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
  #           sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
  #         },
  #         subauthorities: {
  #           term_sub1_key: 'term_sub1_name',
  #           term_sub2_key: 'term_sub2_name',
  #           term_sub3_key: 'term_sub3_name'
  #         }
  #       },
  #       search: {
  #         url: {
  #           :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
  #           :@type => 'IriTemplate',
  #           template: 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}',
  #           variableRepresentation: 'BasicRepresentation',
  #           mapping: [
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'query',
  #               property: 'hydra:freetextQuery',
  #               required: true
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'subauth',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'search_sub1_name'
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'param1',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'delta'
  #             },
  #             {
  #               :@type => 'IriTemplateMapping',
  #               variable: 'param2',
  #               property: 'hydra:freetextQuery',
  #               required: false,
  #               default: 'echo'
  #             }
  #           ]
  #         },
  #         qa_replacement_patterns: {
  #           query: 'query',
  #           subauth: 'subauth'
  #         },
  #         language: ['en', 'fr', 'de'],
  #         results: {
  #           id_predicate: 'http://purl.org/dc/terms/identifier',
  #           label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
  #           altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
  #           sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
  #         },
  #         subauthorities: {
  #           search_sub1_key: 'search_sub1_name',
  #           search_sub2_key: 'search_sub2_name',
  #           search_sub3_key: 'search_sub3_name'
  #         }
  #       }
  #     }
  #   end
  #
  #   it 'returns hash of the full authority configuration' do
  #     expect(full_config.auth_config).to eq full_auth_config
  #   end
  # end
end
