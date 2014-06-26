require 'spec_helper'

describe "QA Routes" do

  routes { Qa::Engine.routes }

  context "listing terms" do
    it "should route to index with an authority" do
      { get: '/terms/vocab' }.should route_to(controller: 'qa/terms', action: 'index', vocab: 'vocab')
    end
    it "should route to index with an authority and a subauthority" do
      { get: '/terms/vocab/sub' }.should route_to(controller: 'qa/terms', action: 'index', vocab: 'vocab', sub_authority: 'sub')
    end
  end

  context "searching for terms" do
    it "should route to searching for an authority" do
      { get: '/search/vocab' }.should route_to(controller: 'qa/terms', action: 'search', vocab: 'vocab')
    end
    it "should route to searching for an authority and a subauthority" do
      { get: '/search/vocab/sub' }.should route_to(controller: 'qa/terms', action: 'search', vocab: 'vocab', sub_authority: 'sub')
    end
  end

  context "displaying a single term" do
    it "should route to an authority" do
      { get: '/show/vocab/term_id' }.should route_to(controller: 'qa/terms', action: 'show', vocab: 'vocab', id: 'term_id')
    end
    it "should route to an authority with a subauthority" do
      { get: '/show/vocab/sub/term_id' }.should route_to(controller: 'qa/terms', action: 'show', vocab: 'vocab', sub_authority: 'sub', id: 'term_id')
    end
  end
  
end
