# frozen_string_literal: true

require_relative '../../lib/antlers'

dirload('spec/fixtures/props/solo_node_var.rbx')
dirload('spec/fixtures/compiled/compiled_node.rbx')

RSpec.describe 'A compiled template' do
  let(:html) do
    <<~HTML.squish
      <h1>Items &amp; more</h1>
      <ul>
        <li>
          &lt;b&gt;One&lt;/b&gt;
          <em>2 tags</em>
          <strong>red</strong><strong>blue</strong>
        </li>
        <li>
          Two
        </li>
      </ul>
      <p>odd: 1 to 3, 3</p>
      <p>even: 2 to 2, 3</p>
      <p></p>
    HTML
  end

  it 'renders variables, fors and ifs as Ruby, and components inside them with the for values' do
    expect(RBX::CompiledNode.render.response.body.read.squish).to eq(html)
  end

  it 'renders the same HTML as walking the nodes' do
    node = RBX::CompiledNode.new
    current_binding = node.instance_eval { binding }
    ast = RBX::CompiledNode.template.ast

    expect(ast.render(current_binding:)).to eq(ast.interpret(current_binding:))
  end

  it 'compiles once' do
    ast = RBX::CompiledNode.template.ast
    RBX::CompiledNode.render

    expect(Antlers::Compiler).not_to receive(:new)
    RBX::CompiledNode.render
    expect(ast.instance_variable_get(:@compiled)).to be_a(Proc)
  end
end
