-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/data_explorer-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---Canonical Positron display name of data type
---@alias jet.ark.comm.data_explorer_backend.column_display_type "boolean"|"string"|"date"|"datetime"|"time"|"interval"|"object"|"array"|"struct"|"unknown"|"floating"|"integer"|"decimal"

---Schema for a column in a table
---@class jet.ark.comm.data_explorer_backend.column_schema
---@field column_name string Name of column as UTF-8 string
---@field column_label? string Display label for column (e.g., from R's label attribute)
---@field column_index integer The position of the column within the table without any column filters
---@field type_name string Exact name of data type used by underlying table
---@field type_display jet.ark.comm.data_explorer_backend.column_display_type Canonical Positron display name of data type
---@field description? string Column annotation / description
---@field children? jet.ark.comm.data_explorer_backend.column_schema[] Schema of nested child types
---@field precision? integer Precision for decimal types
---@field scale? integer Scale for decimal types
---@field timezone? string Time zone for timestamp with time zone
---@field type_size? integer Size parameter for fixed-size types (list, binary)

---@alias jet.ark.comm.data_explorer_backend.column_value integer|string

---Table values formatted as strings
---@class jet.ark.comm.data_explorer_backend.table_data
---@field columns jet.ark.comm.data_explorer_backend.column_value[][] The columns of data

---Formatted table row labels formatted as strings
---@class jet.ark.comm.data_explorer_backend.table_row_labels
---@field row_labels string[][] Zero or more arrays of row labels

---Formatting options for returning data values as strings
---@class jet.ark.comm.data_explorer_backend.format_options
---@field large_num_digits integer Fixed number of decimal places to display for numbers over 1, or in scientific notation
---@field small_num_digits integer Fixed number of decimal places to display for small numbers, and to determine lower threshold for switching to scientific notation
---@field max_integral_digits integer Maximum number of integral digits to display before switching to scientific notation
---@field max_value_length integer Maximum size of formatted value, for truncating large strings or other large formatted values
---@field thousands_sep? string Thousands separator string

---The schema for a table-like object
---@class jet.ark.comm.data_explorer_backend.table_schema
---@field columns jet.ark.comm.data_explorer_backend.column_schema[] Schema for each column in the table

---Provides number of rows and columns in a table
---@class jet.ark.comm.data_explorer_backend.table_shape
---@field num_rows integer Numbers of rows in the table
---@field num_columns integer Number of columns in the table

---Specifies a table row filter based on a single column's values
---@class jet.ark.comm.data_explorer_backend.row_filter
---@field filter_id string Unique identifier for this filter
---@field filter_type jet.ark.comm.data_explorer_backend.row_filter_type Type of row filter to apply
---@field column_schema jet.ark.comm.data_explorer_backend.column_schema Column to apply filter to
---@field condition "and"|"or" The binary condition to use to combine with preceding row filters
---@field is_valid? boolean Whether the filter is valid and supported by the backend, if undefined then true
---@field error_message? string Optional error message when the filter is invalid
---@field params? jet.ark.comm.data_explorer_backend.row_filter_params The row filter type-specific parameters

---Union of row filter parameters
---@alias jet.ark.comm.data_explorer_backend.row_filter_params jet.ark.comm.data_explorer_backend.filter_between|jet.ark.comm.data_explorer_backend.filter_comparison|jet.ark.comm.data_explorer_backend.filter_text_search|jet.ark.comm.data_explorer_backend.filter_set_membership

---Type of row filter
---@alias jet.ark.comm.data_explorer_backend.row_filter_type "between"|"compare"|"is_empty"|"is_false"|"is_null"|"is_true"|"not_between"|"not_empty"|"not_null"|"search"|"set_membership"

---Support status for a row filter type
---@class jet.ark.comm.data_explorer_backend.row_filter_type_support_status
---@field row_filter_type jet.ark.comm.data_explorer_backend.row_filter_type Type of row filter
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this row filter type

---Parameters for the 'between' and 'not_between' filter types
---@class jet.ark.comm.data_explorer_backend.filter_between
---@field left_value string The lower limit for filtering
---@field right_value string The upper limit for filtering

---Parameters for the 'compare' filter type
---@class jet.ark.comm.data_explorer_backend.filter_comparison
---@field op "="|"!="|"<"|"<="|">"|">=" String representation of a binary comparison
---@field value string A stringified column value for a comparison filter

---Parameters for the 'set_membership' filter type
---@class jet.ark.comm.data_explorer_backend.filter_set_membership
---@field values string[] Array of values for a set membership filter
---@field inclusive boolean Filter by including only values passed (true) or excluding (false)

---Parameters for the 'search' filter type
---@class jet.ark.comm.data_explorer_backend.filter_text_search
---@field search_type jet.ark.comm.data_explorer_backend.text_search_type Type of search to perform
---@field term string String value/regex to search for
---@field case_sensitive boolean If true, do a case-sensitive search, otherwise case-insensitive

---Type of string text search filter to perform
---@alias jet.ark.comm.data_explorer_backend.text_search_type "contains"|"not_contains"|"starts_with"|"ends_with"|"regex_match"

---Parameters for the 'match_data_types' filter type
---@class jet.ark.comm.data_explorer_backend.filter_match_data_types
---@field display_types jet.ark.comm.data_explorer_backend.column_display_type[] Column display types to match

---A filter that selects a subset of columns by name, type, or other criteria
---@class jet.ark.comm.data_explorer_backend.column_filter
---@field filter_type jet.ark.comm.data_explorer_backend.column_filter_type Type of column filter to apply
---@field params jet.ark.comm.data_explorer_backend.column_filter_params Parameters for column filter

---Union of column filter type-specific parameters
---@alias jet.ark.comm.data_explorer_backend.column_filter_params jet.ark.comm.data_explorer_backend.filter_text_search|jet.ark.comm.data_explorer_backend.filter_match_data_types

---Type of column filter
---@alias jet.ark.comm.data_explorer_backend.column_filter_type "text_search"|"match_data_types"

---Support status for a column filter type
---@class jet.ark.comm.data_explorer_backend.column_filter_type_support_status
---@field column_filter_type jet.ark.comm.data_explorer_backend.column_filter_type Type of column filter
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this column filter type

---A single column profile request
---@class jet.ark.comm.data_explorer_backend.column_profile_request
---@field column_index integer The column index (absolute, relative to unfiltered table) to profile
---@field profiles jet.ark.comm.data_explorer_backend.column_profile_spec[] Column profiles needed

---Parameters for a single column profile for a request for profiles
---@class jet.ark.comm.data_explorer_backend.column_profile_spec
---@field profile_type jet.ark.comm.data_explorer_backend.column_profile_type Type of column profile
---@field params? jet.ark.comm.data_explorer_backend.column_profile_params Extra parameters for different profile types

---Extra parameters for different profile types
---@alias jet.ark.comm.data_explorer_backend.column_profile_params jet.ark.comm.data_explorer_backend.column_histogram_params|jet.ark.comm.data_explorer_backend.column_histogram_params|jet.ark.comm.data_explorer_backend.column_frequency_table_params|jet.ark.comm.data_explorer_backend.column_frequency_table_params

---Type of analytical column profile
---@alias jet.ark.comm.data_explorer_backend.column_profile_type "null_count"|"summary_stats"|"small_frequency_table"|"large_frequency_table"|"small_histogram"|"large_histogram"

---Support status for a given column profile type
---@class jet.ark.comm.data_explorer_backend.column_profile_type_support_status
---@field profile_type jet.ark.comm.data_explorer_backend.column_profile_type The type of analytical column profile
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this column profile type

---Result of computing column profile
---@class jet.ark.comm.data_explorer_backend.column_profile_result
---@field null_count? integer Result from null_count request
---@field summary_stats? jet.ark.comm.data_explorer_backend.column_summary_stats Results from summary_stats request
---@field small_histogram? jet.ark.comm.data_explorer_backend.column_histogram Results from small histogram request
---@field large_histogram? jet.ark.comm.data_explorer_backend.column_histogram Results from large histogram request
---@field small_frequency_table? jet.ark.comm.data_explorer_backend.column_frequency_table Results from small frequency_table request
---@field large_frequency_table? jet.ark.comm.data_explorer_backend.column_frequency_table Results from large frequency_table request

---Profile result containing summary stats for a column based on the data type
---@class jet.ark.comm.data_explorer_backend.column_summary_stats
---@field type_display jet.ark.comm.data_explorer_backend.column_display_type Canonical Positron display name of data type
---@field number_stats? jet.ark.comm.data_explorer_backend.summary_stats_number Statistics for a numeric data type
---@field string_stats? jet.ark.comm.data_explorer_backend.summary_stats_string Statistics for a string-like data type
---@field boolean_stats? jet.ark.comm.data_explorer_backend.summary_stats_boolean Statistics for a boolean data type
---@field date_stats? jet.ark.comm.data_explorer_backend.summary_stats_date Statistics for a date data type
---@field datetime_stats? jet.ark.comm.data_explorer_backend.summary_stats_datetime Statistics for a datetime data type
---@field other_stats? jet.ark.comm.data_explorer_backend.summary_stats_other Summary statistics for any other data types

---@class jet.ark.comm.data_explorer_backend.summary_stats_number
---@field min_value? string Minimum value as string
---@field max_value? string Maximum value as string
---@field mean? string Average value as string
---@field median? string Sample median (50% value) value as string
---@field stdev? string Sample standard deviation as a string

---@class jet.ark.comm.data_explorer_backend.summary_stats_boolean
---@field true_count integer The number of non-null true values
---@field false_count integer The number of non-null false values

---@class jet.ark.comm.data_explorer_backend.summary_stats_other
---@field num_unique? integer The number of unique values

---@class jet.ark.comm.data_explorer_backend.summary_stats_string
---@field num_empty integer The number of empty / length-zero values
---@field num_unique integer The exact number of distinct values

---@class jet.ark.comm.data_explorer_backend.summary_stats_date
---@field num_unique? integer The exact number of distinct values
---@field min_date? string Minimum date value as string
---@field mean_date? string Average date value as string
---@field median_date? string Sample median (50% value) date value as string
---@field max_date? string Maximum date value as string

---@class jet.ark.comm.data_explorer_backend.summary_stats_datetime
---@field num_unique? integer The exact number of distinct values
---@field min_date? string Minimum date value as string
---@field mean_date? string Average date value as string
---@field median_date? string Sample median (50% value) date value as string
---@field max_date? string Maximum date value as string
---@field timezone? string Time zone for timestamp with time zone

---Parameters for a column histogram profile request
---@class jet.ark.comm.data_explorer_backend.column_histogram_params
---@field method "sturges"|"freedman_diaconis"|"scott"|"fixed" Method for determining number of bins
---@field num_bins integer Maximum number of bins in the computed histogram.
---@field quantiles? number[] Sample quantiles (numbers between 0 and 1) to compute along with the histogram

---Result from a histogram profile request
---@class jet.ark.comm.data_explorer_backend.column_histogram
---@field bin_edges string[] String-formatted versions of the bin edges, there are N + 1 where N is the number of bins
---@field bin_counts integer[] Absolute count of values in each histogram bin
---@field quantiles jet.ark.comm.data_explorer_backend.column_quantile_value[] Sample quantiles that were also requested

---Parameters for a frequency_table profile request
---@class jet.ark.comm.data_explorer_backend.column_frequency_table_params
---@field limit integer Number of most frequently-occurring values to return. The K in TopK

---Result from a frequency_table profile request
---@class jet.ark.comm.data_explorer_backend.column_frequency_table
---@field values jet.ark.comm.data_explorer_backend.column_value[] The formatted top values
---@field counts integer[] Counts of top values
---@field other_count? integer Number of other values not accounted for in counts, excluding nulls/NA values. May be omitted

---An exact or approximate quantile value from a column
---@class jet.ark.comm.data_explorer_backend.column_quantile_value
---@field q number Quantile number; a number between 0 and 1
---@field value string Stringified quantile value
---@field exact boolean Whether value is exact or approximate (computed from binned data or sketches)

---Specifies a column to sort by
---@class jet.ark.comm.data_explorer_backend.column_sort_key
---@field column_index integer Column index (absolute, relative to unfiltered table) to sort by
---@field ascending boolean Sort order, ascending (true) or descending (false)

---For each field, returns flags indicating supported features
---@class jet.ark.comm.data_explorer_backend.supported_features
---@field search_schema jet.ark.comm.data_explorer_backend.search_schema_features Support for 'search_schema' RPC and its features
---@field set_column_filters jet.ark.comm.data_explorer_backend.set_column_filters_features Support ofr 'set_column_filters' RPC and its features
---@field set_row_filters jet.ark.comm.data_explorer_backend.set_row_filters_features Support for 'set_row_filters' RPC and its features
---@field get_column_profiles jet.ark.comm.data_explorer_backend.get_column_profiles_features Support for 'get_column_profiles' RPC and its features
---@field set_sort_columns jet.ark.comm.data_explorer_backend.set_sort_columns_features Support for 'set_sort_columns' RPC and its features
---@field export_data_selection jet.ark.comm.data_explorer_backend.export_data_selection_features Support for 'export_data_selection' RPC and its features
---@field convert_to_code jet.ark.comm.data_explorer_backend.convert_to_code_features Support for 'convert_to_code' RPC and its features

---Feature flags for 'search_schema' RPC
---@class jet.ark.comm.data_explorer_backend.search_schema_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field supported_types jet.ark.comm.data_explorer_backend.column_filter_type_support_status[] A list of supported types

---Feature flags for 'set_column_filters' RPC
---@class jet.ark.comm.data_explorer_backend.set_column_filters_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field supported_types jet.ark.comm.data_explorer_backend.column_filter_type_support_status[] A list of supported types

---Feature flags for 'set_row_filters' RPC
---@class jet.ark.comm.data_explorer_backend.set_row_filters_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field supports_conditions jet.ark.comm.data_explorer_backend.support_status Whether AND/OR filter conditions are supported
---@field supported_types jet.ark.comm.data_explorer_backend.row_filter_type_support_status[] A list of supported types

---Feature flags for 'get_column_profiles' RPC
---@class jet.ark.comm.data_explorer_backend.get_column_profiles_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field supported_types jet.ark.comm.data_explorer_backend.column_profile_type_support_status[] A list of supported types

---Feature flags for 'export_data_selction' RPC
---@class jet.ark.comm.data_explorer_backend.export_data_selection_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field supported_formats jet.ark.comm.data_explorer_backend.export_format[] Export formats supported

---Feature flags for 'set_sort_columns' RPC
---@class jet.ark.comm.data_explorer_backend.set_sort_columns_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method

---Feature flags for convert to code RPC
---@class jet.ark.comm.data_explorer_backend.convert_to_code_features
---@field support_status jet.ark.comm.data_explorer_backend.support_status The support status for this RPC method
---@field code_syntaxes? jet.ark.comm.data_explorer_backend.code_syntax_name[] The syntaxes for converted code

---A selection on the data grid, for copying to the clipboard or other actions
---@class jet.ark.comm.data_explorer_backend.table_selection
---@field kind "single_cell"|"cell_range"|"column_range"|"row_range"|"column_indices"|"row_indices"|"cell_indices" Type of selection, all indices relative to filtered row/column indices
---@field selection jet.ark.comm.data_explorer_backend.data_selection_single_cell|jet.ark.comm.data_explorer_backend.data_selection_cell_range|jet.ark.comm.data_explorer_backend.data_selection_cell_indices|jet.ark.comm.data_explorer_backend.data_selection_range|jet.ark.comm.data_explorer_backend.data_selection_indices A union of selection types

---A selection that contains a single data cell
---@class jet.ark.comm.data_explorer_backend.data_selection_single_cell
---@field row_index integer The selected row index
---@field column_index integer The selected column index

---A selection that contains a rectangular range of data cells
---@class jet.ark.comm.data_explorer_backend.data_selection_cell_range
---@field first_row_index integer The starting selected row index (inclusive)
---@field last_row_index integer The final selected row index (inclusive)
---@field first_column_index integer The starting selected column index (inclusive)
---@field last_column_index integer The final selected column index (inclusive)

---A rectangular cell selection defined by arrays of row and column indices
---@class jet.ark.comm.data_explorer_backend.data_selection_cell_indices
---@field row_indices integer[] The selected row indices
---@field column_indices integer[] The selected column indices

---A contiguous selection bounded by inclusive start and end indices
---@class jet.ark.comm.data_explorer_backend.data_selection_range
---@field first_index integer The starting selected index (inclusive)
---@field last_index integer The final selected index (inclusive)

---A selection defined by a sequence of indices to include
---@class jet.ark.comm.data_explorer_backend.data_selection_indices
---@field indices integer[] The selected indices

---A union of different selection types for column values
---@class jet.ark.comm.data_explorer_backend.column_selection
---@field column_index integer Column index (relative to unfiltered schema) to select data from
---@field spec jet.ark.comm.data_explorer_backend.array_selection Union of selection specifications for array_selection

---Union of selection specifications for array_selection
---@alias jet.ark.comm.data_explorer_backend.array_selection jet.ark.comm.data_explorer_backend.data_selection_range|jet.ark.comm.data_explorer_backend.data_selection_indices

---Exported data format
---@alias jet.ark.comm.data_explorer_backend.export_format "csv"|"tsv"|"html"

---The support status of the RPC method
---@alias jet.ark.comm.data_explorer_backend.support_status "unsupported"|"supported"

---Import options for file-based data sources. Supports options for delimited text files (CSV, TSV) and Excel workbooks (XLSX).
---@class jet.ark.comm.data_explorer_backend.dataset_import_options
---@field has_header_row? boolean Whether the first row contains column headers (for delimited text files and Excel workbooks)
---@field sheet_name? string The name of the worksheet to read (for Excel workbooks). Defaults to the first sheet.

---@class jet.ark.comm.data_explorer_backend.open_dataset_result
---@field error_message? string An error message if opening the dataset failed

---@alias jet.ark.comm.data_explorer_backend.open_dataset.Reply jet.ark.comm.data_explorer_backend.open_dataset_result

---@alias jet.ark.comm.data_explorer_backend.get_schema.Reply jet.ark.comm.data_explorer_backend.table_schema

---@class jet.ark.comm.data_explorer_backend.search_schema_result
---@field matches integer[] The column indices that match the search parameters in the indicated sort order.

---@alias jet.ark.comm.data_explorer_backend.search_schema.Reply jet.ark.comm.data_explorer_backend.search_schema_result

---@alias jet.ark.comm.data_explorer_backend.get_data_values.Reply jet.ark.comm.data_explorer_backend.table_data

---@alias jet.ark.comm.data_explorer_backend.get_row_labels.Reply jet.ark.comm.data_explorer_backend.table_row_labels

---Exported result
---@class jet.ark.comm.data_explorer_backend.exported_data
---@field data string Exported data as a string suitable for copy and paste
---@field format jet.ark.comm.data_explorer_backend.export_format The exported data format

---@alias jet.ark.comm.data_explorer_backend.export_data_selection.Reply jet.ark.comm.data_explorer_backend.exported_data

---Code snippet for the data view
---@class jet.ark.comm.data_explorer_backend.converted_code
---@field converted_code string[] Lines of code that implement filters and sort keys

---@alias jet.ark.comm.data_explorer_backend.convert_to_code.Reply jet.ark.comm.data_explorer_backend.converted_code

---Syntax to use for code conversion
---@class jet.ark.comm.data_explorer_backend.code_syntax_name
---@field code_syntax_name string The name of the code syntax, eg, pandas, polars, dplyr, etc.

---@alias jet.ark.comm.data_explorer_backend.suggest_code_syntax.Reply jet.ark.comm.data_explorer_backend.code_syntax_name

---@alias jet.ark.comm.data_explorer_backend.set_column_filters.Reply any

---The result of applying filters to a table
---@class jet.ark.comm.data_explorer_backend.filter_result
---@field selected_num_rows integer Number of rows in table after applying filters
---@field had_errors? boolean Flag indicating if there were errors in evaluation

---@alias jet.ark.comm.data_explorer_backend.set_row_filters.Reply jet.ark.comm.data_explorer_backend.filter_result

---@alias jet.ark.comm.data_explorer_backend.set_sort_columns.Reply any

---@alias jet.ark.comm.data_explorer_backend.get_column_profiles.Reply any

---Result of setting import options
---@class jet.ark.comm.data_explorer_backend.set_dataset_import_options_result
---@field error_message? string An error message if setting the options failed

---@alias jet.ark.comm.data_explorer_backend.set_dataset_import_options.Reply jet.ark.comm.data_explorer_backend.set_dataset_import_options_result

---@alias jet.ark.comm.data_explorer_backend.open_data_explorer.Reply any

---The current backend state for the data explorer
---@class jet.ark.comm.data_explorer_backend.backend_state
---@field display_name string Variable name or other string to display for tab name in UI
---@field table_shape jet.ark.comm.data_explorer_backend.table_shape Number of rows and columns in table with row/column filters applied
---@field table_unfiltered_shape jet.ark.comm.data_explorer_backend.table_shape Number of rows and columns in table without any filters applied
---@field has_row_labels boolean Indicates whether table has row labels or whether rows should be labeled by ordinal position
---@field column_filters jet.ark.comm.data_explorer_backend.column_filter[] The currently applied column filters
---@field row_filters jet.ark.comm.data_explorer_backend.row_filter[] The currently applied row filters
---@field sort_keys jet.ark.comm.data_explorer_backend.column_sort_key[] The currently applied column sort keys
---@field supported_features jet.ark.comm.data_explorer_backend.supported_features The features currently supported by the backend instance
---@field connected? boolean Optional flag allowing backend to report that it is unable to serve requests. This parameter may change.
---@field error_message? string Optional experimental parameter to provide an explanation when connected=false. This parameter may change.
---@field available_sheets? string[] For Excel workbooks, the names of the worksheets available to read, in workbook order. Absent for non-Excel data sources.

---@alias jet.ark.comm.data_explorer_backend.get_state.Reply jet.ark.comm.data_explorer_backend.backend_state

---@class jet.ark.comm.data_explorer_backend.open_dataset.Params
---@field uri string The resource locator or file path

---Request to open a dataset given a URI
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.open_dataset.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.open_dataset.Reply)
M.open_dataset = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "open_dataset", params, "OpenDatasetReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.get_schema.Params
---@field column_indices integer[] The column indices (relative to the filtered/selected columns) to fetch

---Request schema
---
---Request subset of column schemas for a table-like object
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.get_schema.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.get_schema.Reply)
M.get_schema = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "get_schema", params, "GetSchemaReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.search_schema.Params
---@field filters jet.ark.comm.data_explorer_backend.column_filter[] Column filters to apply when searching, can be empty
---@field sort_order "original"|"ascending_name"|"descending_name"|"ascending_type"|"descending_type" How to sort results: original in-schema order, alphabetical ascending or descending

---Search table schema with column filters, optionally sort results
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.search_schema.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.search_schema.Reply)
M.search_schema = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "search_schema", params, "SearchSchemaReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.get_data_values.Params
---@field columns jet.ark.comm.data_explorer_backend.column_selection[] Array of column selections
---@field format_options jet.ark.comm.data_explorer_backend.format_options Formatting options for returning data values as strings

---Request formatted values from table columns
---
---Request data from table columns with values formatted as strings
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.get_data_values.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.get_data_values.Reply)
M.get_data_values = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "get_data_values", params, "GetDataValuesReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.get_row_labels.Params
---@field selection jet.ark.comm.data_explorer_backend.array_selection Selection of row labels
---@field format_options jet.ark.comm.data_explorer_backend.format_options Formatting options for returning labels as strings

---Request formatted row labels from table
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.get_row_labels.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.get_row_labels.Reply)
M.get_row_labels = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "get_row_labels", params, "GetRowLabelsReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.export_data_selection.Params
---@field selection jet.ark.comm.data_explorer_backend.table_selection The data selection
---@field format jet.ark.comm.data_explorer_backend.export_format Result string format

---Export data selection as a string in different formats
---
---Export data selection as a string in different formats like CSV, TSV, HTML
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.export_data_selection.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.export_data_selection.Reply)
M.export_data_selection = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "export_data_selection", params, "ExportDataSelectionReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.convert_to_code.Params
---@field column_filters jet.ark.comm.data_explorer_backend.column_filter[] Zero or more column filters to apply
---@field row_filters jet.ark.comm.data_explorer_backend.row_filter[] Zero or more row filters to apply
---@field sort_keys jet.ark.comm.data_explorer_backend.column_sort_key[] Zero or more sort keys to apply
---@field code_syntax_name jet.ark.comm.data_explorer_backend.code_syntax_name The code syntax to use for conversion

---Converts the current data view into a code snippet.
---
---Converts filters and sort keys as code in different syntaxes like pandas, polars, data.table, dplyr
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.convert_to_code.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.convert_to_code.Reply)
M.convert_to_code = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "convert_to_code", params, "ConvertToCodeReply", callback)
end

---Suggest code syntax for code conversion
---
---Suggest code syntax for code conversion based on the current backend state
---@param kernel jet.Kernel
---@param comm_id string
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.suggest_code_syntax.Reply)
M.suggest_code_syntax = function(kernel, comm_id, callback)
	return util.rpc_request(kernel, comm_id, "suggest_code_syntax", nil, "SuggestCodeSyntaxReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.set_column_filters.Params
---@field filters jet.ark.comm.data_explorer_backend.column_filter[] Column filters to apply (or pass empty array to clear column filters)

---Set column filters to select subset of table columns
---
---Set or clear column filters on table, replacing any previous filters
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.set_column_filters.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.set_column_filters.Reply)
M.set_column_filters = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "set_column_filters", params, "SetColumnFiltersReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.set_row_filters.Params
---@field filters jet.ark.comm.data_explorer_backend.row_filter[] Zero or more filters to apply

---Set row filters based on column values
---
---Row filters to apply (or pass empty array to clear row filters)
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.set_row_filters.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.set_row_filters.Reply)
M.set_row_filters = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "set_row_filters", params, "SetRowFiltersReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.set_sort_columns.Params
---@field sort_keys jet.ark.comm.data_explorer_backend.column_sort_key[] Pass zero or more keys to sort by. Clears any existing keys

---Set or clear sort-by-column(s)
---
---Set or clear the columns(s) to sort by, replacing any previous sort columns
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.set_sort_columns.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.set_sort_columns.Reply)
M.set_sort_columns = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "set_sort_columns", params, "SetSortColumnsReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.get_column_profiles.Params
---@field callback_id string Async callback unique identifier
---@field profiles jet.ark.comm.data_explorer_backend.column_profile_request[] Array of requested profiles
---@field format_options jet.ark.comm.data_explorer_backend.format_options Formatting options for returning data values as strings

---Async request a batch of column profiles
---
---Async request for a statistical summary or data profile for batch of columns
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.get_column_profiles.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.get_column_profiles.Reply)
M.get_column_profiles = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "get_column_profiles", params, "GetColumnProfilesReply", callback)
end

---@class jet.ark.comm.data_explorer_backend.set_dataset_import_options.Params
---@field options jet.ark.comm.data_explorer_backend.dataset_import_options Import options to apply

---Set import options for file-based data sources
---
---Set import options for file-based data sources (like CSV files) and reimport the data. This method is primarily used by file-based backends like DuckDB.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.data_explorer_backend.set_dataset_import_options.Params
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.set_dataset_import_options.Reply)
M.set_dataset_import_options = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "set_dataset_import_options", params, "SetDatasetImportOptionsReply", callback)
end

---Open a full data explorer for the same data
---
---Creates a new, independent data explorer comm for the same underlying data. The new comm has its own state (filters, sorts). Used when promoting an inline notebook data explorer to a full data explorer panel.
---@param kernel jet.Kernel
---@param comm_id string
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.open_data_explorer.Reply)
M.open_data_explorer = function(kernel, comm_id, callback)
	return util.rpc_request(kernel, comm_id, "open_data_explorer", nil, "OpenDataExplorerReply", callback)
end

---Get the state
---
---Request the current backend state (table metadata, explorer state, and features)
---@param kernel jet.Kernel
---@param comm_id string
---@param callback? fun(res: jet.ark.comm.data_explorer_backend.get_state.Reply)
M.get_state = function(kernel, comm_id, callback)
	return util.rpc_request(kernel, comm_id, "get_state", nil, "GetStateReply", callback)
end

return M
