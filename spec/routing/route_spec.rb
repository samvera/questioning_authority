require 'spec_helper'

describe "QA Routes", type: :routing do
  routes { Qa::Engine.routes }

  context "listing terms" do
    it "routes to index with an authority" do
      expect(get: '/terms/vocab').to route_to(controller: 'qa/terms', action: 'index', vocab: 'vocab')
    end
    it "routes to index with an authority and a subauthority" do
      expect(get: '/terms/vocab/sub').to route_to(controller: 'qa/terms', action: 'index', vocab: 'vocab', subauthority: 'sub')
    end
  end

  context "searching for terms" do
    it "routes to searching for an authority" do
      expect(get: '/search/vocab').to route_to(controller: 'qa/terms', action: 'search', vocab: 'vocab')
    end
    it "routes to searching for an authority and a subauthority" do
      expect(get: '/search/vocab/sub').to route_to(controller: 'qa/terms', action: 'search', vocab: 'vocab', subauthority: 'sub')
    end
  end

  context "displaying a single term" do
    it "routes to an authority" do
      expect(get: '/show/vocab/term_id').to route_to(controller: 'qa/terms', action: 'show', vocab: 'vocab', id: 'term_id')
    end
    it "routes to an authority with a subauthority" do
      expect(get: '/show/vocab/sub/term_id').to route_to(controller: 'qa/terms', action: 'show', vocab: 'vocab', subauthority: 'sub', id: 'term_id')
    end
  end
end
