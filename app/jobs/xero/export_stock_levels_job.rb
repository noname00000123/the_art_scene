class Xero::ExportStockLevelsJob < ActiveJob::Base
  queue_as do
    if urgent_job?
      :high_priority
    else
      :default
    end
  end

  after_perform :notify_manager

  # we assume that we have a class CsvImporter to handle the import
  def perform(filepath)
    return if cancelled?

    XeroExporter.new(filepath).export_stock_levels
  end

  private

  def urgent_job?
    self.arguments.first =~ /\/urgent\//
  end

  def notify_manager
    NotificationMailer.job_done(Spree::User.admin).deliver_later
  end

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
end