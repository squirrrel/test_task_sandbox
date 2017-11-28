class LinesWrapper
  attr_reader :slice_step
  attr_accessor :text, :warning

  def initialize text:, slice_step:
    @text = text.to_s
    @slice_step = slice_step.to_i
    @pattern = /([a-zA-Z0-9\W ]{1,#{slice_step}})(\s|\b\n?)|([a-zA-Z0-9\W ]{1,#{slice_step}})/ rescue Regexp.new(//)
  end

  def perform!
    validate_inputs && (return text if !warning.nil?)
    embed_new_lines!
  end

  private

  attr_reader :pattern

  def embed_new_lines!; text.gsub!(pattern, "\\1\\3\n"); end

  def validate_inputs
    if slice_step.zero?
      @warning = 'Specify slice_step > 0 to wrap lines. Rolling back'
    elsif text.empty?
      @warning = 'Empty input text. Rolling back'
    end
  end
end
