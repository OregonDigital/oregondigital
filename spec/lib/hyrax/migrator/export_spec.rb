require 'spec_helper'
describe Hyrax::Migrator::Export do
  describe 'export_content' do
    let(:exporter) { described_class.new('some_path', 'some_name', 'pidlist.txt') }
    let(:item) { double }
    let(:short_pid) { 'abcde1234' }
    let(:descMetadata) { double }
    let(:graph) { RDF::Graph.new }
    let(:empty_result) { double }
    let(:statement) { RDF::Statement.new(subj, pred, obj) }
    let(:subj) { RDF::URI('http://oregondigital.org/resource/oregondigital:abcde1234') }
    let(:pred) { RDF::URI('http://opaquenamespace.org/ns/contents') }
    let(:obj) { RDF::URI('http://oregondigital.org/resource/oregondigital:abcde1235') }
    let(:dstream) { double }
    let(:content) { double }
    let(:log) { double }

    before do
      allow(Logger).to receive(:new).and_return(log)
      allow(Dir).to receive(:exist?).and_return(true)
      allow(item).to receive(:descMetadata).and_return(descMetadata)
      allow(descMetadata).to receive(:graph).and_return(graph)
    end

    context 'when the item is a cpd' do
      before do
        graph << statement
      end

      context 'when there is a content file' do
        let(:datastreams) { { 'content' => dstream } }

        before do
          allow(item).to receive(:datastreams).and_return(datastreams)
          allow(dstream).to receive(:mimeType).and_return('application/xml')
        end

        it 'does not call File' do
          expect(File).not_to receive(:open)
          exporter.export_content(item, short_pid)
        end
      end

      context 'when there is no content file' do
        let(:datastreams) { { 'thing' => dstream } }

        before do
          allow(item).to receive(:datastreams).and_return(datastreams)
        end
        it 'does not call File' do
          expect(File).not_to receive(:open)
          exporter.export_content(item, short_pid)
        end
      end
    end
    
    context 'when item is not a cpd' do
      context 'when there is a content file' do
        let(:datastreams) { { 'content' => dstream } }
        let(:file) { double }

        before do
          allow(item).to receive(:datastreams).and_return(datastreams)
          allow(dstream).to receive(:mimeType).and_return('image/tiff')
          allow(dstream).to receive(:content).and_return(content)
          allow(graph).to receive(:query).and_return(empty_result)
          allow(empty_result).to receive(:empty?).and_return(true)
          allow(File).to receive(:open).and_return(file)
          allow(file).to receive(:write)
          allow(file).to receive(:close)
          allow(file).to receive(:puts)
          allow(file).to receive(:print)
        end
         
        it 'writes the file' do
          expect(file).to receive(:write)
          exporter.export_content(item, short_pid)
        end
      end

      context 'when there is no content file' do
        let(:datastreams) { { 'thing' => dstream } }

        before do
          allow(item).to receive(:datastreams).and_return(datastreams)
          allow(graph).to receive(:query).and_return(empty_result)
          allow(empty_result).to receive(:empty?).and_return(true)
        end

        it 'logs an error' do
          expect(log).to receive(:error)
          exporter.export_content(item, short_pid)
        end
      end
    end
  end
end


