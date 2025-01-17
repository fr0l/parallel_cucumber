require 'cucumber/formatter/io'
require 'cucumber/formatter/ast_lookup'

module ParallelCucumber
  module Helper
    module Cucumber
      class JsonStatusFormatter
        include ::Cucumber::Formatter::Io

        def initialize(config)
          config.on_event :test_case_finished, &method(:on_test_case_finished)
          config.on_event :test_run_finished, &method(:on_test_run_finished)

          @io     = ensure_io(config.out_stream, nil)
          @result = {}
          @ast_lookup = ::Cucumber::Formatter::AstLookup.new(config)
        end

        def on_test_case_finished(event)
          gherkin_document = @ast_lookup.gherkin_document(event.test_case.location.file)
          details = {status: event.result.to_sym}
          if event.result.respond_to?(:exception)
            details[:exception_classname] = event.result.exception.class.to_s
            details[:exception_message] = event.result.exception.message
          end
          details[:name] = "#{gherkin_document.feature.name}: #{event.test_case.name}"
          details[:finish_time] = Time.now.to_i
          @result[event.test_case.location.to_s] = details
        end

        def on_test_run_finished(*)
          @io.write(@result.to_json)
        end
      end
    end
  end
end

