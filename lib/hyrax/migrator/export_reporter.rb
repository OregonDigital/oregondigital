module Hyrax::Migrator
  ##
  # For use by the exporter in OD2 migration workflow
  # Can add additional items for reporting as required
  class ExportReporter
    def initialize
      @cpd = 0
      @restricted = 0
    end

    def update(item)
      @cpd += 1 if item.compound?
      @restricted += 1 if ((item.read_groups.include? "University-of-Oregon") || (item.read_groups.include? "Oregon-State-University"))
    end

    def log(logger)
      logger.info "Number of CPDs: #{@cpd}"
      logger.info "Number of restricted items: #{@restricted}"
    end
  end
end

