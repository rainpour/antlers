# frozen_string_literal: true

require_relative '../../../lib/antlers'
require_relative '../../../lib/nodes/slot_node'
require_relative '../../fixtures/props/plain_nodes'

dirload('spec/fixtures/layouts/layout_node.rbx')
dirload('spec/fixtures/slots/slot_in_slot.rbx')

# A component's <{ :slot }> inside another component's slot renders what the component was given, not itself again.
RSpec.describe 'A slot inside a slot' do
  def render(node) = node.render.response.body.read.squish

  it 'renders the page in the shell in the layout' do
    expect(render(RBX::SlotInSlotNode)).to eq('<html><h1>Shell Heading</h1><p>Page Text</p></html>')
  end

  it 'renders a slot passed on two components deep' do
    expect(render(RBX::SlotInSlotInSlotNode)).to eq('<html><h1>Shell Heading</h1><section><p>Deep Text</p></section></html>')
  end

  it 'renders a slot passed on to a plain Ruby class that takes it rendered' do
    expect(render(RBX::SlotInPlainSlotNode)).to eq('<section title="Plain"><p>Plain Text</p></section>')
  end
end
