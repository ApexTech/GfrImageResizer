require "spec_helper"

RSpec.describe GfrImageTransformer::Variations do
  let(:image_url) { "https://s3.amazonaws.com/media.listamax.com/listings/2020/02/25/apartment-for-sale-in-chalets-de-la-playa-in-vega-baja-puerto-rico-dc355701a612a0443b574c340996f35a.jpg" }

  let(:encoded_url) { "https://dmekkq419t23o.cloudfront.net/eyJidWNrZXQiOiJtZWRpYS5saXN0YW1heC5jb20iLCJrZXkiOiJsaXN0aW5ncy8yMDIwLzAyLzI1L2FwYXJ0bWVudC1mb3Itc2FsZS1pbi1jaGFsZXRzLWRlLWxhLXBsYXlhLWluLXZlZ2EtYmFqYS1wdWVydG8tcmljby1kYzM1NTcwMWE2MTJhMDQ0M2I1NzRjMzQwOTk2ZjM1YS5qcGciLCJlZGl0cyI6eyJyZXNpemUiOnsid2lkdGgiOjY0MCwiaGVpZ2h0Ijo0ODAsImZpdCI6ImNvdmVyIn19fQ==" }

  it "should chain multiple transformations" do
    image_url = "https://s3.amazonaws.com/media.listamax.com/listings/2020/02/19/shopper.png"
    encoded_url = "https://dmekkq419t23o.cloudfront.net/eyJidWNrZXQiOiJtZWRpYS5saXN0YW1heC5jb20iLCJrZXkiOiJsaXN0aW5ncy8yMDIwLzAyLzE5L3Nob3BwZXIucG5nIiwiZWRpdHMiOnsiZXh0cmFjdCI6eyJ3aWR0aCI6ODI5LCJoZWlnaHQiOjYyMCwibGVmdCI6NTksInRvcCI6MTM0OX0sInJlc2l6ZSI6eyJ3aWR0aCI6MzIwLCJoZWlnaHQiOjI0MCwiZml0IjoiZmlsbCJ9LCJub3JtYWxpemUiOnRydWUsInNoYXJwZW4iOnRydWV9fQ=="

    variations = described_class.for(image_url) do |builder|
      variant(:full_image) { resize(640, 480) }
      variant(:cropped) do
        extract(829, 620, left: 59, top: 1349)
        resize(320, 240, resizer_mode: :fill)
        normalize(true)
        sharpen(true)
      end
    end

    cropped = variations.cropped
    expect(variations.variants.keys).to eq([:full_image, :cropped])
    expect(cropped.url).to eq(encoded_url)
    expect(cropped.width).to eq(320)
    expect(cropped.height).to eq(240)
  end
end
