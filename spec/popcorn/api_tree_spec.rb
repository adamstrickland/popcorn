require "spec_helper"

describe Popcorn::ApiTree do
  let(:root) { File.expand_path(File.join(File.dirname(__FILE__), "../fixtures")) }
  let(:klass) { described_class }
  let(:instance) { klass.new(root) }

  context "#apis" do
    subject { instance.apis }
    it { should have(3).items }
    it { expect(subject.map(&:title)).to include "Foo API", "Bar API", "Baz API" }
  end
end
