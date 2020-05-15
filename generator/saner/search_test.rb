# frozen_string_literal: true

module Inferno
  module Generator
    module SearchTest
      def create_search_test(sequence, search_param)
        test_key = :"search_by_#{search_param[:names].map(&:underscore).join('_')}"
        search_test = {
          tests_that: "Server returns valid results for #{sequence[:resource]} search by #{search_param[:names].join('+')}.",
          key: test_key,
          index: sequence[:tests].length + 1,
          optional: search_param[:expectation] != 'SHALL',
          description: %(
            A server #{search_param[:expectation]} support searching by #{search_param[:names].join('+')} on the #{sequence[:resource]} resource.
            This test will pass if resources are returned and match the search criteria.
            )
        }
        search_params = get_search_params(search_param[:names], sequence)
        search_test[:test_code] = %(
          #{search_params}
          skip 'Could not find parameter value for #{search_param[:names]} to search by.' if search_params.any? { |_param, value| value.nil? }

          reply = get_resource_by_params(versioned_resource_class('#{sequence[:resource]}'), search_params)

          assert_response_ok(reply)
          assert_bundle_response(reply)

          bundled_resources = fetch_all_bundled_resources(reply)
          save_resource_references(versioned_resource_class('#{sequence[:resource]}'), bundled_resources, '#{sequence[:profile]}')
          validate_reply_entries(bundled_resources, search_params)
        )
        sequence[:tests] << search_test
      end

      def get_search_params(search_parameters, sequence)
        param_values = search_parameters.map do |param|
          search_param_description = sequence[:search_param_descriptions][param.to_sym]
          expressions = search_param_description[:expression]
            .map { |expression| expression.gsub(/(?<!\w)class(?!\w)/, 'local_class')}
            .map { |expression| expression.split('.').slice(1..-1).join('.')}

          "#{param.gsub('-','_')}_value = resolve_element_from_paths_comma_delimited(@resource_found, '#{expressions.join(',')}') { |el| get_value_for_search_param(el).present? }"
        end

        search_params= search_parameters.map do |param|
          "'#{param}': get_value_for_search_param(#{param.gsub('-','_')}_value)"
        end

        search_param_string = %(
          #{param_values.join("\n")}
          search_params = {
            #{search_params.join(",\n")}
          }
        )

        search_param_string
      end

      def structure_to_string(struct)
        if struct.is_a? Hash
          %({
            #{struct.map { |k, v| "#{k}: #{structure_to_string(v)}" }.join(",\n")}
          })
        elsif struct.is_a? Array
          %([
            #{struct.map { |el| structure_to_string(el) }.join(",\n")}
          ])
        elsif struct.is_a? String
          "'#{struct}'"
        else
          "''"
        end
      end
    end
  end
end
