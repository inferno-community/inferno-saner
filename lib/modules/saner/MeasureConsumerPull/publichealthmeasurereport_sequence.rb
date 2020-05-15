# frozen_string_literal: true

module Inferno
  module Sequence
    class MeasureConsumerPullPublicHealthMeasureReportSequence < SequenceBase
      title 'Saner Public Health Measure Report Tests'

      description 'Verify support for the server capabilities required by the Saner Public Health Measure Report.'

      details %(
      )

      test_id_prefix 'SPHMR'

      requires :measurereport_id
      conformance_supports :MeasureReport

      def validate_resource_item(resource, property, value)
        case property

        when '_id'
          values_found = resolve_path_comma_delimited(resource, 'id')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "_id in MeasureReport/#{resource.id} (#{values_found}) does not match _id requested (#{value})"

        when 'code'
          values_found = resolve_path_comma_delimited(resource, 'group.code.coding.code,group.population.code.coding.code,group.stratifier.code.coding.code,group.stratifier.stratum.component.code.coding.code,group.stratifier.stratum.population.code.coding.code')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "code in MeasureReport/#{resource.id} (#{values_found}) does not match code requested (#{value})"

        when 'date'
          values_found = resolve_path_comma_delimited(resource, 'date')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "date in MeasureReport/#{resource.id} (#{values_found}) does not match date requested (#{value})"

        when 'measure'
          values_found = resolve_path_comma_delimited(resource, 'measure')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "measure in MeasureReport/#{resource.id} (#{values_found}) does not match measure requested (#{value})"

        when 'subject'
          values_found = resolve_path_comma_delimited(resource, 'subject.reference')
          match_found = values_found.any? { |reference| [value, 'Patient/' + value].include? reference }
          assert match_found, "subject in MeasureReport/#{resource.id} (#{values_found}) does not match subject requested (#{value})"

        when 'period'
          values_found = resolve_path_comma_delimited(resource, 'period')
          match_found = values_found.any? { |date| validate_date_search(value, date) }
          assert match_found, "period in MeasureReport/#{resource.id} (#{values_found}) does not match period requested (#{value})"

        when 'reporter'
          values_found = resolve_path_comma_delimited(resource, 'reporter.reference')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "reporter in MeasureReport/#{resource.id} (#{values_found}) does not match reporter requested (#{value})"

        end
      end

      @resource_found = nil

      test :resource_read do
        metadata do
          id '01'
          name 'Server returns correct MeasureReport resource from the MeasureReport read interaction'
          link 'http://build.fhir.org/ig/AudaciousInquiry/fhir-saner/index.html'
          description %(
            This test will attempt to Reference to MeasureReport can be resolved and read.
          )
          versions :r4
        end

        resource_id = @instance.measurereport_id
        read_response = validate_read_reply(FHIR::MeasureReport.new(id: resource_id), FHIR::MeasureReport)
        @resource_found = read_response.resource
        @raw_resource_found = read_response.response[:body]
      end

      test :search_by__id do
        metadata do
          id '02'
          name 'Server returns valid results for MeasureReport search by _id.'
          link ''
          description %(

            A server SHALL support searching by _id on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        _id_value = resolve_element_from_paths_comma_delimited(@resource_found, 'id') { |el| get_value_for_search_param(el).present? }
        search_params = {
          '_id': get_value_for_search_param(_id_value)
        }

        skip 'Could not find parameter value for ["_id"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_date do
        metadata do
          id '03'
          name 'Server returns valid results for MeasureReport search by date.'
          link ''
          description %(

            A server SHALL support searching by date on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        date_value = resolve_element_from_paths_comma_delimited(@resource_found, 'date') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'date': get_value_for_search_param(date_value)
        }

        skip 'Could not find parameter value for ["date"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_measure do
        metadata do
          id '04'
          name 'Server returns valid results for MeasureReport search by measure.'
          link ''
          description %(

            A server SHALL support searching by measure on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        measure_value = resolve_element_from_paths_comma_delimited(@resource_found, 'measure') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'measure': get_value_for_search_param(measure_value)
        }

        skip 'Could not find parameter value for ["measure"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_subject do
        metadata do
          id '05'
          name 'Server returns valid results for MeasureReport search by subject.'
          link ''
          description %(

            A server SHALL support searching by subject on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        subject_value = resolve_element_from_paths_comma_delimited(@resource_found, 'subject') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'subject': get_value_for_search_param(subject_value)
        }

        skip 'Could not find parameter value for ["subject"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_period do
        metadata do
          id '06'
          name 'Server returns valid results for MeasureReport search by period.'
          link ''
          description %(

            A server SHALL support searching by period on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        period_value = resolve_element_from_paths_comma_delimited(@resource_found, 'period') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'period': get_value_for_search_param(period_value)
        }

        skip 'Could not find parameter value for ["period"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_reporter do
        metadata do
          id '07'
          name 'Server returns valid results for MeasureReport search by reporter.'
          link ''
          description %(

            A server SHALL support searching by reporter on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        reporter_value = resolve_element_from_paths_comma_delimited(@resource_found, 'reporter') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'reporter': get_value_for_search_param(reporter_value)
        }

        skip 'Could not find parameter value for ["reporter"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_code do
        metadata do
          id '08'
          name 'Server returns valid results for MeasureReport search by code.'
          link ''
          optional
          description %(

            A server SHOULD support searching by code on the MeasureReport resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        code_value = resolve_element_from_paths_comma_delimited(@resource_found, 'group.code,group.population.code,group.stratifier.code,group.stratifier.stratum.component.code,group.stratifier.stratum.population.code') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'code': get_value_for_search_param(code_value)
        }

        skip 'Could not find parameter value for ["code"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('MeasureReport'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('MeasureReport'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :validate_resources do
        metadata do
          id '09'
          name 'The MeasureReport resource returned from the first Read test is valid according to the profile http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport.'
          link ''
          description %(

          )
          versions :r4
        end

        skip 'No resource found from Read test' unless @resource_found.present?

        test_resource_against_profile('MeasureReport', @raw_resource_found, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasureReport')
      end
    end
  end
end
