require 'spec_helper'

describe FedoraLens do
  include ActiveModel::Lint::Tests

  class TestClass
    include FedoraLens
    attribute :title, [RDF::DC11.title, Lenses.single, Lenses.literal_to_string]
    # attribute :xml_title, [RDF::DC11.title, Lenses.single]
  end

  # for ActiveModel::Lint::Tests
  def setup
    @model = TestClass.new
  end

  subject { TestClass.new }

  describe ".find" do
    context "when the object doesn't exist" do
      it "should raise an error" do
        expect{ TestClass.find('bahvejlavawwv') }.to raise_error Ldp::NotFound
      end
    end

    context "when the object exists" do
      let(:existing) { TestClass.create(title: "created resource") }
      subject { TestClass.find(existing.id) }
      it { should be_kind_of TestClass }
      its(:id) { should eq existing.id }
    end
  end

  describe ".delete" do
    subject { TestClass.create(title: "created resource") }

    it "should be deleted" do
      subject.delete
      expect{ TestClass.find(subject.id) }.to raise_error Ldp::NotFound
    end
  end

  describe ".create" do
    subject { TestClass.create(attributes) }
    context "with a hash" do
      let(:attributes) { { title: "created resource" } }
      it "creates a resource" do
        expect(TestClass.find(subject.id).title).to eq "created resource"
      end
    end
    context "with nil" do
      let(:attributes) { nil }
      it "creates a resource" do
        expect(TestClass.find(subject.id)).to be_kind_of TestClass
      end
    end
  end

  describe "child nodes" do
    subject { TestClass.create( title: "created resource" ) }
    it "should raise an error about a missing dsid" do
      expect { subject.create(title: 'bar') }.to raise_error ArgumentError
    end
    it "should create one" do
      obj = subject.create('descMetadata', title: 'bar')
      expect(obj.id).to eq "#{subject.id}/descMetadata"
    end
  end

  describe ".save" do
    it "saves a new resource" do
      m = TestClass.new(title: "created resource")
      m.save
      TestClass.find(m.id).title.should eq "created resource"
    end

    it "saves an updated resource" do
      m = TestClass.create(title: "created resource")
      m.reload
      m.title = "changed title"
      m.save
      TestClass.find(m.id).title.should eq "changed title"
    end

    context "with a supplied id" do
      subject { TestClass.new(TestClass.id_to_uri('foobar')) }

      it "saves with that id" do
        expect(subject.new_record?).to be_true
        expect(subject.save).to be_true
        expect(subject.new_record?).to be_false
      end

    end

  end

  describe ".attribute" do
    it "makes a setter/getter" do
      subject.title = "foo"
      subject.title.should eq "foo"
    end

    it "loads from rdf" do
    end

    it "mixes rdf and xml" do
    end
  end
end
