# frozen_string_literal: true

module Inferno
  module Sequence
    class MeasureConsumerPullSanerResourceLocationSequence < SequenceBase
      title 'Resource Location Profile Tests'

      description 'Verify support for the server capabilities required by the Resource Location Profile.'

      details %(
      )

      test_id_prefix 'RLP'

      requires :location_id
      conformance_supports :Location

      def validate_resource_item(resource, property, value)
        case property

        when '_id'
          values_found = resolve_path_comma_delimited(resource, 'id')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "_id in Location/#{resource.id} (#{values_found}) does not match _id requested (#{value})"

        when '_lastUpdated'
          values_found = resolve_path_comma_delimited(resource, 'meta.lastUpdated')
          match_found = values_found.any? { |date| validate_date_search(value, date) }
          assert match_found, "_lastUpdated in Location/#{resource.id} (#{values_found}) does not match _lastUpdated requested (#{value})"

        when 'name'
          values_found = resolve_path_comma_delimited(resource, 'name,alias')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "name in Location/#{resource.id} (#{values_found}) does not match name requested (#{value})"

        when 'identifier'
          values_found = resolve_path_comma_delimited(resource, 'identifier.value')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "identifier in Location/#{resource.id} (#{values_found}) does not match identifier requested (#{value})"

        when 'address'
          values_found = resolve_path_comma_delimited(resource, 'address')
          match_found = values_found.any? do |address|
            address&.text&.start_with?(value) ||
              address&.city&.start_with?(value) ||
              address&.state&.start_with?(value) ||
              address&.postalCode&.start_with?(value) ||
              address&.country&.start_with?(value)
          end
          assert match_found, "address in Location/#{resource.id} (#{values_found}) does not match address requested (#{value})"

        when 'address-city'
          values_found = resolve_path_comma_delimited(resource, 'address.city')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "address-city in Location/#{resource.id} (#{values_found}) does not match address-city requested (#{value})"

        when 'address-country'
          values_found = resolve_path_comma_delimited(resource, 'address.country')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "address-country in Location/#{resource.id} (#{values_found}) does not match address-country requested (#{value})"

        when 'address-postalcode'
          values_found = resolve_path_comma_delimited(resource, 'address.postalCode')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "address-postalcode in Location/#{resource.id} (#{values_found}) does not match address-postalcode requested (#{value})"

        when 'address-state'
          values_found = resolve_path_comma_delimited(resource, 'address.state')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "address-state in Location/#{resource.id} (#{values_found}) does not match address-state requested (#{value})"

        when 'address-use'
          values_found = resolve_path_comma_delimited(resource, 'address.use')
          values = value.split(/(?<!\\),/).each { |str| str.gsub!('\,', ',') }
          match_found = values_found.any? { |value_in_resource| values.include? value_in_resource }
          assert match_found, "address-use in Location/#{resource.id} (#{values_found}) does not match address-use requested (#{value})"

        end
      end

      @resource_found = nil

      test :resource_read do
        metadata do
          id '01'
          name 'Server returns correct Location resource from the Location read interaction'
          link 'http://build.fhir.org/ig/AudaciousInquiry/fhir-saner/index.html'
          description %(
            This test will attempt to Reference to Location can be resolved and read.
          )
          versions :r4
        end

        resource_id = @instance.location_id
        read_response = validate_read_reply(FHIR::Location.new(id: resource_id), FHIR::Location)
        @resource_found = read_response.resource
        @raw_resource_found = read_response.response[:body]
      end

      test :search_by__id do
        metadata do
          id '02'
          name 'Server returns valid results for Location search by _id.'
          link ''
          description %(

            A server SHALL support searching by _id on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        _id_value = resolve_element_from_paths_comma_delimited(@resource_found, 'id') { |el| get_value_for_search_param(el).present? }
        search_params = {
          '_id': get_value_for_search_param(_id_value)
        }

        skip 'Could not find parameter value for ["_id"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by__last_updated do
        metadata do
          id '03'
          name 'Server returns valid results for Location search by _lastUpdated.'
          link ''
          description %(

            A server SHALL support searching by _lastUpdated on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        _lastUpdated_value = resolve_element_from_paths_comma_delimited(@resource_found, 'meta.lastUpdated') { |el| get_value_for_search_param(el).present? }
        search_params = {
          '_lastUpdated': get_value_for_search_param(_lastUpdated_value)
        }

        skip 'Could not find parameter value for ["_lastUpdated"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_name do
        metadata do
          id '04'
          name 'Server returns valid results for Location search by name.'
          link ''
          description %(

            A server SHALL support searching by name on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        name_value = resolve_element_from_paths_comma_delimited(@resource_found, 'name,alias') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'name': get_value_for_search_param(name_value)
        }

        skip 'Could not find parameter value for ["name"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_identifier do
        metadata do
          id '05'
          name 'Server returns valid results for Location search by identifier.'
          link ''
          description %(

            A server SHALL support searching by identifier on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        identifier_value = resolve_element_from_paths_comma_delimited(@resource_found, 'identifier') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'identifier': get_value_for_search_param(identifier_value)
        }

        skip 'Could not find parameter value for ["identifier"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address do
        metadata do
          id '06'
          name 'Server returns valid results for Location search by address.'
          link ''
          description %(

            A server SHALL support searching by address on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address': get_value_for_search_param(address_value)
        }

        skip 'Could not find parameter value for ["address"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address_city do
        metadata do
          id '07'
          name 'Server returns valid results for Location search by address-city.'
          link ''
          description %(

            A server SHALL support searching by address-city on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_city_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address.city') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address-city': get_value_for_search_param(address_city_value)
        }

        skip 'Could not find parameter value for ["address-city"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address_country do
        metadata do
          id '08'
          name 'Server returns valid results for Location search by address-country.'
          link ''
          description %(

            A server SHALL support searching by address-country on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_country_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address.country') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address-country': get_value_for_search_param(address_country_value)
        }

        skip 'Could not find parameter value for ["address-country"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address_postalcode do
        metadata do
          id '09'
          name 'Server returns valid results for Location search by address-postalcode.'
          link ''
          description %(

            A server SHALL support searching by address-postalcode on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_postalcode_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address.postalCode') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address-postalcode': get_value_for_search_param(address_postalcode_value)
        }

        skip 'Could not find parameter value for ["address-postalcode"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address_state do
        metadata do
          id '10'
          name 'Server returns valid results for Location search by address-state.'
          link ''
          description %(

            A server SHALL support searching by address-state on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_state_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address.state') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address-state': get_value_for_search_param(address_state_value)
        }

        skip 'Could not find parameter value for ["address-state"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :search_by_address_use do
        metadata do
          id '11'
          name 'Server returns valid results for Location search by address-use.'
          link ''
          description %(

            A server SHALL support searching by address-use on the Location resource.
            This test will pass if resources are returned and match the search criteria.

          )
          versions :r4
        end

        address_use_value = resolve_element_from_paths_comma_delimited(@resource_found, 'address.use') { |el| get_value_for_search_param(el).present? }
        search_params = {
          'address-use': get_value_for_search_param(address_use_value)
        }

        skip 'Could not find parameter value for ["address-use"] to search by.' if search_params.any? { |_param, value| value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Location'), search_params)

        assert_response_ok(reply)
        assert_bundle_response(reply)

        bundled_resources = fetch_all_bundled_resources(reply)
        save_resource_references(versioned_resource_class('Location'), bundled_resources, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
        validate_reply_entries(bundled_resources, search_params)
      end

      test :validate_resources do
        metadata do
          id '12'
          name 'The Location resource returned from the first Read test is valid according to the profile http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location.'
          link ''
          description %(

          )
          versions :r4
        end

        skip 'No resource found from Read test' unless @resource_found.present?

        test_resource_against_profile('Location', @raw_resource_found, 'http://hl7.org/fhir/us/saner/StructureDefinition/saner-resource-location')
      end
    end
  end
end
