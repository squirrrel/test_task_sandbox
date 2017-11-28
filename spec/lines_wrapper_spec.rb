require './lib/lines_wrapper'

describe LinesWrapper do
  describe 'overall behaviour' do
    let(:text)       { 'To be or not to be-that is the question' }
    let(:slice_step) { rand(10) }

    context 'basic wrapper check' do
      let(:basic_wrapper) { LinesWrapper.new(text: text, slice_step: slice_step) }
      subject { basic_wrapper.perform! }
      # cuts no more than slice_step-ish number of characters each
      it      { is_expected.not_to match(/.{#{slice_step+1},}/) }

      # leaves whitespaces neither at the start nor at the end of the line
      it      { is_expected.not_to match(/\\n\s|\s\\n/) }

      context 'does not leave a single letter aside.', skip: 'better to check against real syllables' do
        it    { is_expected.not_to match(/\b[a-zA-Z0-9]{1}\b/) }
      end
    end

    context 'with the slice_step equals 0' do
      let(:zero_step_wrapper) { LinesWrapper.new(text: text, slice_step: 0) }
      subject { zero_step_wrapper.perform! }
      # it does not perform any job
      it      { allow(subject).to receive(:validate_input) }
      it      { is_expected.not_to receive(:embed_new_lines!) }

      # it keeps text in its initial state
      it      { is_expected.to eq(text) }
    end

    context 'with the non-numeric slice_step' do
      let(:nonnumeric_wrapper) { LinesWrapper.new(text: text, slice_step: '--num') }
      context 'slice_step test' do
        subject { nonnumeric_wrapper.slice_step }
        it      { is_expected.to be_zero }
      end

      context 'does not perform any job and keeps text in its initial state' do
        subject { nonnumeric_wrapper.perform! }
        it      { is_expected.not_to receive(:embed_new_lines!) }
        it      { is_expected.to eq(text) }
      end
    end

    context 'with empty text' do
      let(:empty_text_wrapper) { LinesWrapper.new(text: nil, slice_step: 5) }

      context 'works out an empty string for the text parameter' do
        subject { empty_text_wrapper.text }
        it      { is_expected.to be_empty }
      end
      context 'does not perform any job and return empty string' do
        subject { empty_text_wrapper.perform! }
        it      { is_expected.not_to receive(:embed_new_lines!) }
        it      { is_expected.to be_empty }
      end
    end
  end
end
