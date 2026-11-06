# frozen_string_literal: true

require_relative '../../lib/nodes/solo_node'

dirload('spec/fixtures/props/solo_node_var.rbx')
dirload('spec/fixtures/props/solo_node_with_child.rbx')

RSpec.describe RBX::SoloNodeWithChild do
  subject(:solo_node) { described_class }

  describe '#render' do
    it 'renders child with prop' do
      expect(solo_node.render.response.body.read).to eq('<html><strong>Parent Variable</strong></html>')
    end
  end
end
