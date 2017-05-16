require "spec_helper"

describe Popcorn::ApiDef do
  let(:klass) { described_class }
  let(:root) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures")) }
  let(:instance) { klass.new(root, api_file) }

  describe "when the api file includes other files" do
    let(:api_file) { File.join(root, "apis/#{api_name}.yml") }
    let(:definitions_file) { File.join(root, "definitions/#{api_name}.yml") }
    let(:paths_file) { File.join(root, "paths/#{api_name}.yml") }

    subject { instance }

    shared_examples_for :multi_file_api_def do
      it { should respond_to :filename }
      it { should respond_to :content }

      context "#definition" do
        subject { instance.definition }
        it { should be_a Hash }
        it { expect(subject.keys).to include("swagger", "info", "paths", "definitions") }

        it { expect(subject["paths"]).to be_a Hash }
        it { expect(subject["paths"]).to have(2).items }
        it { expect(subject["paths"].keys).to include "/foos" }
        it { expect(subject["definitions"].keys).to include "foo" }
      end

      context "#files" do
        subject { instance.files }
        it { should be_an Array }
        it { should have(3).items }
        it { should include api_file, definitions_file, paths_file }
      end

      context "#info" do
        subject { instance.info }
        it { should be_a Hash }
        it { should have(2).items }
        it { expect(subject.keys).to include "version", "title" }
      end

      context "#definition_files" do
        subject { instance.definition_files }
        it { should be_an Array }
        it { should have(1).items }
        it { should eql [File.join(root, "definitions/foo.yml")] }
      end

      context "#definitions" do
        subject { instance.definitions }
        it { should be_a Hash }
        it { should have(1).items }
        it { expect(subject.keys).to include "foo" }
      end

      context "#path_files" do
        subject { instance.path_files }
        it { should be_an Array }
        it { should have(1).items }
        it { should eql [File.join(root, "paths/foo.yml")] }
      end

      context "#paths" do
        subject { instance.paths }
        it { should be_a Hash }
        it { should have(2).items }
        it { expect(subject.keys).to include "/foos", "/foos/{id}" }
      end
    end

    context "one sub-file per category" do
      let(:api_name) { "foo" }
      it_should_behave_like :multi_file_api_def
    end

    context "multiple sub-file per category" do
      let(:api_name) { "quux" }
      # it_should_behave_like :multi_file_api_def
    end
  end

  describe "when the api is defined in a single file" do
    let(:api_file) { File.join(root, "apis/bar.yml") }

    subject { instance }

    context "#definition" do
      subject { instance.definition }
      it { should be_a Hash }
      it { expect(subject.keys).to include("swagger", "info", "paths", "definitions") }

      it { expect(subject["paths"]).to be_a Hash }
      it { expect(subject["paths"]).to have(1).items }
      it { expect(subject["paths"].keys).to include "/bars" }
      it { expect(subject["definitions"].keys).to include "bar" }
    end

    context "#files" do
      subject { instance.files }
      it { should be_an Array }
      it { should have(1).items }
      it { should include api_file }
    end

    context "#info" do
      subject { instance.info }
      it { should be_a Hash }
      it { should have(2).items }
      it { expect(subject.keys).to include "version", "title" }
    end

    context "#definition_files" do
      subject { instance.definition_files }
      it { should be_nil }
    end

    context "#path_files" do
      subject { instance.path_files }
      it { should be_nil }
    end

    context "#definitions" do
      subject { instance.definitions }
      it { should be_a Hash }
      it { should have(1).items }
      it { expect(subject.keys).to include "bar" }
    end

    context "#paths" do
      subject { instance.paths }
      it { should be_a Hash }
      it { should have(1).items }
      it { expect(subject.keys).to include "/bars" }
    end
  end

  describe "when the api is defined both inline and in multiple files" do
    let(:api_file) { File.join(root, "apis/baz.yml") }
    let(:paths_file) { File.join(root, "paths/baz.yml") }

    subject { instance }

    context "#definition" do
      subject { instance.definition }
      it { should be_a Hash }
      it { expect(subject.keys).to include("swagger", "info", "paths", "definitions") }

      it { expect(subject["paths"]).to be_a Hash }
      it { expect(subject["paths"]).to have(2).items }
      it { expect(subject["paths"].keys).to include "/bazs", "/bazs/{id}" }
      it { expect(subject["definitions"].keys).to include "baz" }
    end

    context "#files" do
      subject { instance.files }
      it { should be_an Array }
      it { should have(2).items }
      it { should include api_file, paths_file }
    end

    context "#info" do
      subject { instance.info }
      it { should be_a Hash }
      it { should have(2).items }
      it { expect(subject.keys).to include "version", "title" }
    end

    context "#definition_files" do
      subject { instance.definition_files }
      it { should be_nil }
    end

    context "#path_files" do
      subject { instance.path_files }
      it { should be_an Array }
      it { should have(1).item }
    end

    context "#definitions" do
      subject { instance.definitions }
      it { should be_a Hash }
      it { should have(1).items }
      it { expect(subject.keys).to include "baz" }
    end

    context "#paths" do
      subject { instance.paths }
      it { should be_a Hash }
      it { should have(2).items }
      it { expect(subject.keys).to include "/bazs", "/bazs/{id}" }
    end
  end

  describe "::parse" do
    subject { klass.parse(files) }

    let(:api_name) { "foo" }
    let(:dir) { File.join(root, "paths") }

    before do
      files.each do |file|
        expect(File).to exist(file)
      end
    end

    context "when there is one file" do
      let(:files) { [File.join(dir, "#{api_name}.yml")] }

      it "should parse a set of yaml files into a single hash of the data" do
        expect(subject).to be_a Hash
      end
    end

    context "when there are multiple files" do
      let(:files) do
        %w[quux quuux].map{ |f| File.join(dir, "#{f}.yml") }
      end

      it "should parse a set of yaml files into a single hash of the data" do
        expect(subject).to be_a Hash
      end
    end
  end
end
