# frozen_string_literal: true

module Inferno
  module Sequence
    class MeasureConsumerPullPublicHealthMeasureSequence < SequenceBase
      title 'Saner Public Health Measure Tests'

      description 'Verify support for the server capabilities required by the Saner Public Health Measure.'

      details %(
      )

      test_id_prefix 'SPHM'

      requires :measure_id
      conformance_supports :Measure

      def validate_resource_item(resource, property, value)
        case property

        when 'url'
          values_found = resolve_path(resource, 'url')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "url in Measure/#{resource.id} (#{values_found}) does not match url requested (#{value})"

        when 'code'
          values_found = resolve_path(resource, 'topic.coding.code')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "code in Measure/#{resource.id} (#{values_found}) does not match code requested (#{value})"

        when 'definition-text'
          values_found = resolve_path(resource, 'title')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "definition-text in Measure/#{resource.id} (#{values_found}) does not match definition-text requested (#{value})"

        end
      end

      @resource_found = nil

      test :resource_read do
        metadata do
          id '01'
          name 'Server returns correct Measure resource from the Measure read interaction'
          link 'http://build.fhir.org/ig/AudaciousInquiry/fhir-saner/index.html'
          description %(
            This test will attempt to Reference to Measure can be resolved and read.
          )
          versions :r4
        end

        resource_id = @instance.measure_id
        read_response = validate_read_reply(FHIR::Measure.new(id: resource_id), FHIR::Measure)
        @resource_found = read_response.resource
        @raw_resource_found = read_response.response[:body]
      end

      test :search_by_url do
        metadata do
          id '02'
          name 'Server returns valid results for Measure search by url.'
          link ''
          optional
          description %(

            A server SHOULD support searching by url on the Measure resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        search_params = {
          'url': get_value_for_search_param(resolve_element_from_path(@resource_found, 'url') { |el| get_value_for_search_param(el).present? })
        }
        skip 'Could not find parameter value for ["url"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Measure'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Measure'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasure')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_code do
        metadata do
          id '03'
          name 'Server returns valid results for Measure search by code.'
          link ''
          optional
          description %(

            A server SHOULD support searching by code on the Measure resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        search_params = {
          'code': get_value_for_search_param(resolve_element_from_path(@resource_found, 'topic') { |el| get_value_for_search_param(el).present? })
        }
        skip 'Could not find parameter value for ["code"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Measure'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Measure'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasure')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_definition_text do
        metadata do
          id '04'
          name 'Server returns valid results for Measure search by definition-text.'
          link ''
          optional
          description %(

            A server SHOULD support searching by definition-text on the Measure resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        search_params = {
          'definition-text': get_value_for_search_param(resolve_element_from_path(@resource_found, 'title') { |el| get_value_for_search_param(el).present? })
        }
        skip 'Could not find parameter value for ["definition-text"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Measure'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Measure'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasure')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :validate_resources do
        metadata do
          id '05'
          name 'The Measure resource returned from the first Read test is valid according to the profile http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasure.'
          link ''
          description %(

          )
          versions :r4
        end

        skip 'No resource found from Read test' unless @resource_found.present?

        test_resource_against_profile('Measure', @raw_resource_found, 'http://hl7.org/fhir/us/saner/StructureDefinition/PublicHealthMeasure')
      end
    end
  end
end
