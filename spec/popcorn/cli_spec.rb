require "spec_helper"

describe Popcorn::Cli do
  let(:klass) { described_class }
  let(:arguments) { [] }
  let(:command) { nil }
  let(:commands) { [command, arguments].flatten.compact }
  let(:actor) { klass.start commands }

  subject do
    capture { actor }
  end

  describe "help" do
    it { expect(subject).to match %r{generate SRC \[DEST\]} }
  end

  describe "generate" do
    let(:command) { "generate" }
    let(:src) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures")) }
    let(:dest) { File.expand_path(File.join(File.dirname(__FILE__), "../../tmp/popcorn")) }
    let(:arguments) { [src, dest] }

    shared_examples_for :base_generation do
      it "should support the generate command" do
        expect(subject).to match %r{Popcorn is doin' some generatin'!}
      end

      it "should report the source directory" do
        expect(subject).to match src
      end

      it "should report the destination directory" do
        expect(subject).to match dest
      end
    end

    shared_examples_for :file_generation do |c|
      it "should report the count of files produced (#{c})" do
        expect(subject).to match %r{generated #{c} files:}
      end
    end

    shared_examples_for :multi_file_generation do
      it "should report the files generated" do
        expect(subject).to match "index.html"
        expect(subject).to match "bar.yml"
        expect(subject).to match "baz.yml"
        expect(subject).to match "foo.yml"
      end
    end

    shared_examples_for :swagger_generation do
      it "should report the files generated" do
        expect(subject).to match "swagger.json"
      end
    end

    context "with no options" do
      it_should_behave_like :base_generation
      it_should_behave_like :file_generation, 5
      it_should_behave_like :multi_file_generation
    end

    context "with --no-multi option" do
      let(:arguments) { [src, dest, "--no-multi"] }

      it_should_behave_like :base_generation
      it_should_behave_like :file_generation, 1
      it_should_behave_like :swagger_generation
    end

    context "with --swagger option" do
      let(:arguments) { [src, dest, "--swagger"] }

      it_should_behave_like :base_generation
      it_should_behave_like :file_generation, 6
      it_should_behave_like :swagger_generation
    end
  end
end
