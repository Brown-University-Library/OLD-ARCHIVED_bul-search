# Declare assets not included in javascripts/application.js
#
# These are files that are loaded per-page rather than packaged on the
# main minified JavaScript file.
Rails.application.config.assets.precompile += %w( catalog_results_availability.js )
Rails.application.config.assets.precompile += %w( catalog_record_availability.js )
