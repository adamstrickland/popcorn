require "spec_helper"

require "tempfile"

describe Popcorn::ApiDef do
  let(:klass) { described_class }
  let(:root) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures/base_case")) }

  describe "instance methods" do
    let(:instance) { klass.new(root, api_file) }

    shared_examples_for :api_def do |defname, pathcount, filecount|
      context "#definition" do
        subject { instance.definition }
        it { should be_a Hash }
        it { expect(subject.keys).to include("swagger", "info", "paths", "definitions") }

        it { expect(subject["paths"]).to be_a Hash }
        it { expect(subject["paths"]).to have(pathcount).items }
        it { expect(subject["paths"].keys).to include "/#{defname}s" }
        it { expect(subject["definitions"].keys).to include defname }
      end

      context "#files" do
        subject { instance.files }
        it { should be_an Array }
        it { should have(filecount).items }
      end

      context "#info" do
        subject { instance.info }
        it { should be_a Hash }
        it { should have_at_least(2).items }
        it { expect(subject.keys).to include "version", "title" }
      end

      context "#definitions" do
        subject { instance.definitions }
        it { should be_a Hash }
        it { should have_at_least(1).items }
        it { expect(subject.keys).to include defname }
      end

      context "#paths" do
        subject { instance.paths }
        it { should be_a Hash }
        it { should have_at_least(1).items }
        it { expect(subject.keys).to include "/#{defname}s" }
        # it { expect(subject.keys).to include "/#{defname}s/{id}" }
      end
    end

    describe "when the api file includes other files" do
      let(:api_file) { File.join(root, "apis/#{api_name}.yml") }
      let(:definitions_file) { File.join(root, "definitions/#{api_name}.yml") }
      let(:paths_file) { File.join(root, "paths/#{api_name}.yml") }

      subject { instance }

      shared_examples_for :multi_file_api_def do |defname, pathcount, filecount|
        it { should respond_to :filename }
        it { should respond_to :content }

        it_should_behave_like :api_def, defname, pathcount, filecount

        context "#files" do
          subject { instance.files }
          it { should include api_file, definitions_file, paths_file }
        end

        context "#definition_files" do
          subject { instance.definition_files }
          it { should be_an Array }
          it { should have_at_least(1).items }
          it { should include File.join(root, "definitions/#{defname}.yml") }
        end

        context "#path_files" do
          subject { instance.path_files }
          it { should be_an Array }
          it { should have_at_least(1).items }
          it { should include File.join(root, "paths/#{defname}.yml") }
        end
      end

      context "one sub-file per category" do
        let(:api_name) { "foo" }
        it_should_behave_like :multi_file_api_def, "foo", 2, 3
      end

      context "multiple sub-file per category" do
        let(:api_name) { "quux" }
        it_should_behave_like :multi_file_api_def, "quux", 3, 5
      end
    end

    describe "when the api is defined in a single file" do
      let(:api_file) { File.join(root, "apis/bar.yml") }

      subject { instance }

      it_should_behave_like :api_def, "bar", 1, 1

      context "#definition_files" do
        subject { instance.definition_files }
        it { should be_nil }
      end

      context "#path_files" do
        subject { instance.path_files }
        it { should be_nil }
      end
    end

    describe "when the api is defined both inline and in multiple files" do
      let(:api_file) { File.join(root, "apis/baz.yml") }
      let(:paths_file) { File.join(root, "paths/baz.yml") }

      subject { instance }

      it_should_behave_like :api_def, "baz", 2, 2

      context "#definition_files" do
        subject { instance.definition_files }
        it { should be_nil }
      end

      context "#path_files" do
        subject { instance.path_files }
        it { should be_an Array }
        it { should have(1).item }
      end
    end

    # describe "other cases" do
    #   let(:api_file) { File.join(root, "apis/bar.yml") }

    #   subject { instance }

    #   it_should_behave_like :api_def, "bar", 1, 1

    #   context "#definition_files" do
    #     subject { instance.definition_files }
    #     it { should be_nil }
    #   end

    #   context "#path_files" do
    #     subject { instance.path_files }
    #     it { should be_nil }
    #   end
    # end
  end

  describe "class methods" do
    describe "::parse" do
      subject { klass.parse(files) }

      let(:api_name) { "foo" }
      let(:dir) { File.join(root, "paths") }

      context "when the file(s) exist" do
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

        context "when a file is empty" do
          let(:file) { Tempfile.new }
          let(:files){ [File.expand_path(file)] }

          after { file.unlink }

          it { expect{ subject }.to raise_error "Invalid YAML file" }
        end
      end

      context "when the file(s) don't exist" do
        let(:files){ [File.expand_path("./nonexistent_file.yml")] }

        it { expect{ subject }.to raise_error %r{Non-existent file} }
      end
    end
  end
end
