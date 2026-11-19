# frozen_string_literal: true

require_relative '../../../lib/antlers'

RSpec.describe 'Nested blocks' do
  def render(template, **locals)
    current_binding = binding
    locals.each { |name, value| current_binding.local_variable_set(name, value) }
    Antlers.render(ast: Antlers.ast(template:), current_binding:).gsub(/\s+/, ' ').strip
  end

  let(:nested_if) do
    <<~RBX
      <{ if: outer }>
        <p>outer</p>
        <{ if: inner }>
          <p>inner</p>
        <{ :if }>
        <p>after inner</p>
      <{ :if }>
      <p>after outer</p>
    RBX
  end

  it 'closes an if inside an if with its own end tag' do
    expect([render(nested_if, outer: true, inner: true), render(nested_if, outer: true, inner: false),
            render(nested_if, outer: false, inner: true)])
      .to eq(['<p>outer</p> <p>inner</p> <p>after inner</p> <p>after outer</p>',
              '<p>outer</p> <p>after inner</p> <p>after outer</p>', '<p>after outer</p>'])
  end

  it 'closes a for inside a for with its own end tag' do
    template = <<~RBX
      <{ for: row in: rows }><{ for: cell in: row }>{cell}<{ :for }>;<{ :for }>
    RBX

    expect(render(template, rows: [%w[a b], %w[c]])).to eq('ab;c;')
  end
end
