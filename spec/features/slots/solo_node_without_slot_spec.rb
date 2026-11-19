# frozen_string_literal: true

# When lowevent is required then antlers will send an event to render_template.
require 'lowevent'

require_relative '../../../lib/nodes/slot_node'
require_relative '../../../lib/nodes/var_node'

dirload('spec/fixtures/slots/solo_node_without_slot.rbx')
dirload('spec/fixtures/layouts/layout_node_with_prop.rbx')

RSpec.describe RBX::SoloNodeWithoutSlot do
  describe '#render' do
    it "renders nothing for a component's slot when it's used without one" do
      expect(described_class.render.response.body.read.squish).to eq('<html>LayoutHappy</html>')
    end
  end
end
