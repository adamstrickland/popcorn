require "spec_helper"

require "popcorn/api_def"

describe Popcorn::Generator do
  let(:klass) { described_class }
  let(:instance) { klass.new(apis, dest) }

  let(:dest) { Dir.mktmpdir("popcorn-generator-") }
  let(:root) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures/base_case")) }
  let(:api_def) { ::Popcorn::ApiDef.new(root, api_file) }
  let(:def_file) { "foo.yml" }
  let(:api_file) { File.join(root, "#{klass::API_DIR}/#{def_file}") }
  let(:apis) { [api_def] }

  before do
    expect(File).to exist dest
    FileUtils.chmod_R("a=rwx", dest)
    expect(File).to be_writable dest
  end

  after do
    FileUtils.remove_entry(dest)
  end

  subject { instance }

  it { should respond_to :generate! }

  shared_examples_for :generate_swagger_file do
    it { expect(File).to exist File.join(dest, "swagger.json") }
  end

  shared_examples_for :generate_multi_files do
    it { expect(File).to exist File.join(dest, "index.html") }
    it { expect(File).to exist File.join(dest, klass::API_DIR, "foo.yml") }
  end

  describe "#generate!" do
    subject { retval }
    before { retval }

    context "when invoked with no options" do
      let(:retval) { instance.generate! }

      it_should_behave_like :generate_multi_files
    end

    context "when invoked with options" do
      let(:retval) { instance.generate!(options) }
      let(:options) { {} }

      context "and swagger: true" do
        let(:options) { {swagger: true} }

        it_should_behave_like :generate_multi_files
        it_should_behave_like :generate_swagger_file
      end

      context "and multi: false" do
        let(:options) { {multi: false} }

        it_should_behave_like :generate_swagger_file
      end
    end
  end

  describe "#_create_directories" do
    let(:retval) { instance.send(:_create_directories) }
    let(:api_dir) { File.join(dest, klass::API_DIR) }

    subject { retval }
    before { retval }

    it { expect(File).to exist dest }
    it { expect(File).to be_writable dest }
    it { expect(File).to be_directory dest }
    it { expect(File).not_to be_sticky dest }

    it { expect(File).to exist api_dir }
    it { expect(File).to be_writable api_dir }
    it { expect(File).to be_directory api_dir }
    it { expect(File).not_to be_sticky api_dir }
  end

  describe "#_write_multi_files" do
    let(:retval) { instance.send(:_write_multi_files) }
    subject { retval }
    before { retval }
  end

  describe "#_write_file" do
    let(:path) { File.join(dest, "nonsense.txt") }
    let(:content) { "ABC123" }
    let(:retval) { instance.send(:_write_file, path, content) }

    subject { retval }
    before { retval }
    it { expect(File).to exist path }
    it "should be the same" do
      actual = File.open(path) do |io|
        io.readlines(nil)
      end.first
      expect(actual).to eql content
    end

    it { expect(File).not_to be_executable path }
  end

  describe "#_api_defs" do
    let(:retval) { instance.send(:_api_defs) }
    subject { retval }

    it { should be_an Array }
    it { should have(1).item }

    context ":first" do
      subject { retval.first }
      it { expect(subject.first).to eql def_file }
    end
  end

  describe "#_swagger_file_elements" do
    let(:retval) { instance.send(:_swagger_file_elements) }
    subject { retval }
    before { retval }
    it { should be_an Array }

    context "first item" do
      let(:item) { retval.first }

      context "[0]" do
        subject { item[0] }

        it { expect(subject).to be_a String }
        it { expect(subject).to match %r{.+API} }
      end

      context "[1]" do
        subject { item[1] }

        it { expect(subject).to be_a Hash }
        it { expect(subject.keys).to include "/foos" }
      end

      context "[2]" do
        subject { item[2] }

        it { expect(subject).to be_a Hash }
        it { expect(subject.keys).to include "foo" }
      end
    end
  end

  shared_examples_for :swagger_file_data do
    it { should be_a Hash }
    it { expect(subject.keys).to include "paths", "definitions" }
  end

  describe "#_swagger_file_data" do
    let(:retval) { instance.send(:_swagger_file_data) }
    subject { retval }
    before { retval }

    it_should_behave_like :swagger_file_data
  end

  describe "#_swagger_file_titles" do
    let(:retval) { instance.send(:_swagger_file_titles) }
    subject { retval }
    before { retval }

    it { should be_an Array }
    it { should include_match %r{Foo API} }
  end

  shared_examples_for :swagger_info_block do
    it { should be_a Hash }
    it { expect(subject.keys).to include "info" }
    it { expect(subject["info"]).to be_a Hash }
    it { expect(subject["info"].keys).to include "name" }
    it { expect(subject["info"]["name"]).to match %r{Foo API} }
  end

  describe "#_swagger_file_info_block" do
    let(:retval) { instance.send(:_swagger_file_info_block) }
    subject { retval }
    before { retval }

    it_should_behave_like :swagger_info_block
  end

  describe "#_swagger_file_content" do
    let(:retval) { instance.send(:_swagger_file_content) }
    subject { retval }
    before { retval }

    it_should_behave_like :swagger_info_block
    it_should_behave_like :swagger_file_data
  end

  describe "#_write_swagger_file" do
    let(:retval) { instance.send(:_write_swagger_file) }
    subject { retval }
    before { retval }

    it_should_behave_like :generate_swagger_file
  end

  describe "#apis" do
    subject { instance.apis }
    it { should be_an Array }
    it { should eql apis }
  end

  describe "#index_register" do
    subject { instance.index_register }
    it { should be_a Hash }
    it { should have(1).item }
    it { expect(subject.keys.first).to match %r{index.html} }
    it { expect(subject.values.first).to match %r{<title>Swagger UI</title>} }
  end

  describe "#template_context" do
    subject { instance.template_context }
    let(:expected) do
      {
        "apis" => [
          {"file" => "apis/foo.yml", "name" => "Foo API"}
        ]
      }
    end
    it { should be_a Hash }
    it { should have(1).item }
    it { expect(subject.keys).to include "apis" }
    it { expect(subject).to eql expected }
    it { expect(subject["apis"].first["file"]).to match %r{#{def_file}} }
    it { expect(subject["apis"].first["name"]).to match %r{Foo API} }
  end

  describe "#api_registers" do
    subject { instance.api_registers }
    it { should be_a Hash }
    it { should have(1).item }
    it { expect(subject.keys.first).to match %r{#{def_file}} }
    it { expect(subject.values.first).to match %r{Foo API} }
  end

  describe "#file_registers" do
    subject { instance.file_registers }
    it { should be_a Hash }
    it { should have(2).item }
    it { expect(subject.keys).to include_match %r{index.html}, %r{#{def_file}} }
  end

  describe "#index_file_template_path" do
    subject { instance.index_file_template_path }
    it { expect(File).to exist subject }
  end

  describe "#index_file_template_content" do
    subject { instance.index_file_template_content }
    it { should match %r{<title>Swagger UI</title>} }
    it { should match %r{<li>.+href="/swagger-ui.html.+} }
  end

  describe "#index_file_content" do
    subject { instance.index_file_content(context) }

    context "when no api group is supplied" do
      let(:context) { {} }
      it { should_not match %r{<li>.+href="/swagger-ui.html.+} }
    end

    context "when an api group is supplied" do
      let(:context) { {apis: [file: "foo.yml", name: "Foo API"]} }
      it { should match %r{<li>.+href="/swagger-ui.html\?url=/apis/foo.yml">Foo API.+} }
    end
  end

  describe "#paths" do
    subject { instance.paths }

    it { should be_an Array }
    it { should have(2).items }
    it { expect(File).to exist subject.first }
    it { expect(File).not_to exist subject.last }
  end
end
