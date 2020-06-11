# frozen_string_literal:true

module Hyrax::Migrator
  # Methods to verify that asset is reviewed
  class AssetStatus
    attr_accessor :work

    def verify_status
      return 'status: destroyed' if @work.workflowMetadata.destroyed

      return 'status: unreviewed' unless @work.workflowMetadata.reviewed

      'ok'
    end
  end
end
