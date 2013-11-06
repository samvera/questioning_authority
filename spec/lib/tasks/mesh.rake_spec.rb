require 'spec_helper'
require 'rake'
require 'stringio'

describe "mesh rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "mesh", ["#{Rails.root}/lib/tasks", "#{Rails.root}/../../lib/tasks"], []
    Rake::Task.define_task(:environment)  # rspec has loaded rails
  end

  describe "mesh:import" do
    before do
      @task_name = "mesh:import"
      @output = StringIO.new
      $stdout = @output
    end
    after :all do
      $stdout = STDOUT
    end
    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end
    it "should require $MESH_FILE to be set" do
      old_mesh_file = ENV.delete('MESH_FILE')
      @rake[@task_name].invoke
      @output.seek(0)
      @output.read.should =~ /Need to set \$MESH_FILE with path to file to ingest/
      ENV['MESH_FILE'] = old_mesh_file
    end
    it "should create or update all records in the config file" do
      ENV['MESH_FILE'] = "dummy"
      input = StringIO.new("*NEWRECORD\nUI = 5\nMH = test\n")
      File.should_receive(:open).with("dummy").and_yield(input)
      @rake[@task_name].invoke
      term = Qa::SubjectMeshTerm.find_by_term_id(5)
      term.should_not be_nil
      term.term.should == "test"
      ENV['MESH_FILE'] = nil
    end
  end
end
