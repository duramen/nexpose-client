module Nexpose
# Constants useful across the Nexpose module.
# Configuration structure for scheduled maintenance.
  class ScheduledMaintenance < APIObject
    require 'json'
    include JsonSerializer

    # Whether or not this maintenance schedule is enabled. Defaults to true if not set
    attr_accessor :enabled
    # Valid schedule types: daily, hourly, monthly-date, monthly-day, weekly.
    attr_accessor :schedule_type
    # The repeat interval based upon type.
    attr_accessor :schedule_interval
    # The earliest date to generate the report on (in ISO 8601 format).
    attr_accessor :schedule_start
    # Whether the reindex task should run. Defaults to true if not set
    attr_accessor :reindex
    # Whether the compression task should run. Defaults to true if not set
    attr_accessor :compress
    # Whether the cleanup task should run. Defaults to true if not set
    attr_accessor :cleanup
    # Whether the maintenance should pause all local scans or wait for local scans to complete. Defaults to true if not set
    attr_accessor :pause_local_scans
    # Cancellation window in minutes for scheduled DB maintenance. Defaults to 0 if not set
    attr_accessor :cancellation_period

    def initialize(start:, enabled: true, type:, interval:, reindex: true, compress: true, cleanup: true, pause_local_scans: true, cancellation_period: 0)
      @schedule_start = start
      @enabled = enabled
      @schedule_type = type
      @schedule_interval = interval.to_i
      @reindex = reindex
      @compress = compress
      @cleanup = cleanup
      @pause_local_scans = pause_local_scans
      @cancellation_period = cancellation_period.to_i
    end

    def to_json
      JSON.generate(to_h)
    end

    def save(nsc)
      params = to_json
      AJAX.post(nsc, '/api/2.1/schedule_maintenance/', params, AJAX::CONTENT_TYPE::JSON)
    end

    def self.from_hash(hash)
      repeat_backup_hash = hash[:repeat_type]
      backup = new(start: hash[:start_date],
                   enabled: hash[:enabled],
                   type: repeat_backup_hash[:type],
                   interval: repeat_backup_hash[:interval],
                   reindex: hash[:reindex],
                   compress: hash[:compression],
                   cleanup: hash[:cleanup],
                   pause_local_scans: hash[:pause_local_scans],
                   cancellation_period: hash[:cancellation_period])
      backup
    end

    def to_h
      maintenance_hash = {
          start_date: @schedule_start,
          enabled: @enabled,
          cleanup: @cleanup,
          reindex: @reindex,
          compression: @compress,
          pause_local_scans: @pause_local_scans,
          cancellation_period: @cancellation_period
      }
      repeat_hash= {
          type: @schedule_type,
          interval: @schedule_interval
      }
      maintenance_hash[:repeat_type] = repeat_hash
      maintenance_hash
    end

    def self.load(nsc)
      uri = '/api/2.1/schedule_maintenance/'
      resp = AJAX.get(nsc, uri, AJAX::CONTENT_TYPE::JSON)
      hash = JSON.parse(resp, symbolize_names: true).first
      Nexpose::ScheduledMaintenance.from_hash(hash || [])
    end

    def self.delete(nsc)
      AJAX.delete(nsc, '/api/2.1/schedule_maintenance/', AJAX::CONTENT_TYPE::JSON)
    end
  end
end