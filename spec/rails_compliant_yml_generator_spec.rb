require './lib/rails_compliant_yml_generator'

describe RailsCompliantYMLGenerator do
  let(:simple_yml_file)     { './lib/translations_simple.yml' }
  let(:basic_yml_generator) { RailsCompliantYMLGenerator.new(simple_yml_file) }

  context 'gets file parsed' do
    context 'file property is no empty' do
      subject { basic_yml_generator.cat_file }
      it      { is_expected.not_to be_empty }
    end
    context 'it looks like a yml file' do
      subject { basic_yml_generator.cat_file.first }
      it      { is_expected.to match(/(.+)(?:|\n)/) }
    end
  end

  context 'generates a hash to feed it to #to_yaml method' do
    context 'initially the hash is empty' do
      subject { basic_yml_generator.h }
      it      { is_expected.to be_empty }
    end
    context 'it is obtained after perform!' do
      subject { basic_yml_generator.perform!.h }
      it      { is_expected.not_to be_empty }
      it      { is_expected.to respond_to(:compare_by_identity) }
    end
  end

  context 'splits period-separated key into yaml nested structure' do
    context 'no dot-separated words as yaml keys' do
      subject { basic_yml_generator.perform!.yaml_result }
      it      { is_expected.not_to match(/\.+/) }
    end
    context 'no more than one word as a yml key' do
      let(:pattern) { Regexp.new(/(\b[^:\.' ][\<\/a-zA-Z0-9\_\-\>]+\b){2}\:/) }
      subject { basic_yml_generator.perform!.yaml_result.scan(pattern) }
      it      { is_expected.to be_empty }
    end
  end

  it { expect { basic_yml_generator.pattern }.to raise_error(NoMethodError, /private .* called/) }

  context 'test different value formats' do
    context 'allows html-tags as yaml values' do
      let(:html_snippet) { '<strong>Cat</strong>' }

      before { File.stub(:readlines).and_return(["'en.cat': #{html_snippet}\n"]) }

      let(:generator) { RailsCompliantYMLGenerator.new('simple_yml_file').perform! }
      subject { generator.h.dig('en', 'cat') }
      it      { is_expected.to eql(html_snippet) }
    end

    context 'allows word expressions as yaml values' do
      let(:multi_word_snippet) { 'Indeed lazy cat' }

      before { File.stub(:readlines).and_return(["'en.cat': #{multi_word_snippet}\n"]) }

      let(:generator) { RailsCompliantYMLGenerator.new('simple_yml_file').perform! }
      subject { generator.h.dig('en', 'cat') }
      it      { is_expected.to eql(multi_word_snippet) }
    end

    context 'allows dot-separated sentances as yaml values', skip: 'not implemented yet' do
      let(:dot_separated_snippet) { 'Indeed lazy cat. Wont even miau' }

      before { File.stub(:readlines).and_return(["'en.cat': #{dot_separated_snippet}\n"]) }

      let(:generator) { RailsCompliantYMLGenerator.new('simple_yml_file').perform! }
      subject { generator.h.dig('en', 'cat') }
      it      { is_expected.to eql(dot_separated_snippet) }
    end
  end

  describe '::generate_result_file' do
    let(:filename)    { 'test.yml' }
    let(:result_yaml) { basic_yml_generator.perform!.yaml_result }

    before(:each) do
      basic_yml_generator.perform!
      RailsCompliantYMLGenerator.generate_result_file(
        target_filename: filename,
        yml_contents: result_yaml
      )
    end

    after(:each) { File.delete(filename) }

    it { expect(File.exists?(filename)).to be_truthy }
    it { expect(File.read(filename)).to eql(result_yaml) }
  end

  describe "#get_parent_accessed" do
    context '# access current elements parent in a nested hash' do
      let(:line)                  { [:en, :pets, :types, :cat] }
      let(:h)                     { {en: {pets: {types: {cat: 'Cat'}}}} }
      let(:dot_separated_snippet) { 'Indeed lazy cat. Wont even miau' }

      before { basic_yml_generator.instance_variable_set(:@h, h) }

      subject { basic_yml_generator.send :get_parent_accessed, line.index(line.last), line }
      it      { is_expected.to eql({cat: 'Cat'})}
    end
  end
end
