require "spec_helper"

require "popcorn/generator"

describe Popcorn::Api do
  let(:klass) { described_class }

  subject { klass }

  it { should respond_to :generate }

  describe "::generate" do
    let(:src) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures")) }
    let(:dest) { File.expand_path(File.join(File.dirname(__FILE__), "../../tmp/popcorn")) }

    context "when called with no options" do
      subject { klass.generate(src, dest) }
    end

    context "when called with no options" do
      let(:options) do
        {
          swagger: false
        }
      end

      it "should pass the options on to the generator" do
        generator = double
        expect(::Popcorn::Generator).to receive(:new).and_return(generator)
        expect(generator).to receive(:generate!).with(options)

        klass.generate(src, dest, options)
      end
    end
  end

  # before do
  #   expect(File).to exist dest
  # end

  # after do
  #   FileUtils.remove_entry(dest)
  #   expect(File).not_to exist dest
  # end

  # describe "::generate" do
  #   context "when called with no options" do
  #     subject { klass.generate(src, dest) }

  #     context "an index file" do
  #       it { expect(File).to exist File.join(dest, "index.html") }
  #     end

  #     context "an api directory" do
  #       let(:api_dir) { File.join(dest, "apis") }

  #       # it { expect(File).to exist api_dir }
  #       # it { expect(File).to be_directory(api_dir) }
  #       # it { expect(Dir.entries(api_dir)).to have(3).items }
  #       # it { expect(Dir.entries(api_dir)).to include "foo.yml", "bar.yml", "baz.yml" }
  #     end
  #   end
  # end
end
